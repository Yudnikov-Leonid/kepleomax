import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kepleomax/core/auth/auth_controller.dart';
import 'package:kepleomax/core/data/auth_repository.dart';
import 'package:kepleomax/core/data/chats_repository.dart';
import 'package:kepleomax/core/data/connection_repository.dart';
import 'package:kepleomax/core/data/data_sources/chats_api_data_sources.dart';
import 'package:kepleomax/core/data/data_sources/messages_api_data_sources.dart';
import 'package:kepleomax/core/data/db/local_database_manager.dart';
import 'package:kepleomax/core/data/files_repository.dart';
import 'package:kepleomax/core/data/local_data_sources/chats_local_data_source.dart';
import 'package:kepleomax/core/data/local_data_sources/messages_local_data_source.dart';
import 'package:kepleomax/core/data/local_data_sources/users_local_data_source.dart';
import 'package:kepleomax/core/data/messenger/combine_cache_and_api.dart';
import 'package:kepleomax/core/data/messenger/messenger_repository.dart';
import 'package:kepleomax/core/data/post_repository.dart';
import 'package:kepleomax/core/data/user_repository.dart';
import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/core/flavor.dart';
import 'package:kepleomax/core/mocks/fake_user_api.dart';
import 'package:kepleomax/core/mocks/mock_messages_web_socket.dart';
import 'package:kepleomax/core/mocks/mock_token_provider.dart';
import 'package:kepleomax/core/mocks/mockito_mocks.mocks.dart';
import 'package:kepleomax/core/network/apis/auth/auth_api.dart';
import 'package:kepleomax/core/network/apis/chats/chats_api.dart';
import 'package:kepleomax/core/network/apis/files/files_api.dart';
import 'package:kepleomax/core/network/apis/messages/messages_api.dart';
import 'package:kepleomax/core/network/apis/posts/post_api.dart';
import 'package:kepleomax/core/network/apis/profile/profile_api.dart';
import 'package:kepleomax/core/network/apis/user/user_api.dart';
import 'package:kepleomax/core/network/middlewares/auth_interceptor.dart';
import 'package:kepleomax/core/network/token_provider.dart';
import 'package:kepleomax/core/network/websockets/messages_web_socket.dart';
import 'package:kepleomax/core/settings/app_settings.dart';
import 'package:kepleomax/firebase_options.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../logger.dart';

Future<Dependencies> initializeDependencies({bool useMocks = false}) async {
  final dp = Dependencies();

  for (final step in _steps) {
    try {
      if (useMocks && step.callForTests != null) {
        await step.callForTests!(dp);
        continue;
      }
      await step.call(dp);
    } catch (e, st) {
      logger.e('Error while initializing step ${step.name}: $e', stackTrace: st);
      rethrow;
    }
  }

  return dp;
}

List<_InitializationStep> _steps = [
  _InitializationStep('storages', (dp) async {
    dp.sharedPreferences = await SharedPreferences.getInstance();
    dp.appSettings = AppSettingsImpl(prefs: dp.sharedPreferences);
    dp.secureStorage = const FlutterSecureStorage();
    CachedNetworkImage.logLevel = CacheManagerLogLevel.verbose;
  }),

  _InitializationStep('local_data_sources', (dp) async {
    final db = await LocalDatabaseManager.getDatabase();
    dp.database = db;
    dp.usersLocalDataSource = UsersLocalDataSourceImpl(
      database: db,
      prefs: dp.sharedPreferences,
    );
    dp.messagesLocalDataSource = MessagesLocalDataSourceImpl(database: db);
    dp.chatsLocalDataSource = ChatsLocalDataSourceImpl(database: db);
  }),

  _InitializationStep('dioLogger, dio', (dp) async {
    dp.prettyDioLogger = PrettyDioLogger(
      request: kDebugMode,
      requestHeader: kDebugMode,
      requestBody: kDebugMode,
      responseHeader: kDebugMode,
      responseBody: kDebugMode,
      error: kDebugMode,
      logPrint: (Object object) => debugPrint(object.toString(), wrapWidth: 1024),
    );

    final dio = Dio(
      BaseOptions(
        validateStatus: (_) => true,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
      ),
    )..interceptors.add(dp.prettyDioLogger);

    dp.dio = dio;
  }),

  _InitializationStep(
    'token_provider',
    (dp) {
      dp.tokenProvider = TokenProviderImpl(
        prefs: dp.sharedPreferences,
        secureStorage: dp.secureStorage,
        // needs its own dio, cause the current one will be locked
        dio: Dio(
          BaseOptions(
            validateStatus: (_) => true,
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 10),
          ),
        )..interceptors.add(dp.prettyDioLogger),
      );
    },
    callForTests: (dp) {
      dp.tokenProvider = MockTokenProvider();
    },
  ),

  _InitializationStep(
    'auth_apis',
    (dp) {
      dp.authApi = AuthApi(dp.dio, flavor.baseUrl);
      dp.userApi = UserApi(dp.dio, flavor.baseUrl);
      dp.profileApi = ProfileApi(dp.dio, flavor.baseUrl);
      dp.filesApi = FilesApi(dp.dio, flavor.baseUrl);
    },
    callForTests: (dp) {
      dp.authApi = AuthApi(dp.dio, flavor.baseUrl);
      dp.userApi = FakeUserApi();
      dp.profileApi = ProfileApi(dp.dio, flavor.baseUrl);
      dp.filesApi = FilesApi(dp.dio, flavor.baseUrl);
    },
  ),

  _InitializationStep('auth', (dp) async {
    dp.authRepository = AuthRepositoryImpl(authApi: dp.authApi);
    dp.userRepository = UserRepositoryImpl(
      profileApi: dp.profileApi,
      filesApi: dp.filesApi,
      userApi: dp.userApi,
      usersLocalDataSource: dp.usersLocalDataSource,
    );

    final authController = AuthControllerImpl(
      authRepository: dp.authRepository,
      userRepository: dp.userRepository,
      tokenProvider: dp.tokenProvider,
      prefs: dp.sharedPreferences,
    );
    authController.init();
    dp.authController = authController;

    dp.dio.interceptors.add(
      AuthInterceptor(
        tokenProvider: dp.tokenProvider,
        authController: dp.authController,
      ),
    );
  }),

  _InitializationStep(
    'web_socket',
    (dp) {
      dp.messagesWebSocket = MessagesWebSocketImpl(
        baseUrl: flavor.baseUrl,
        tokenProvider: dp.tokenProvider,
      );
    },
    callForTests: (dp) {
      dp.messagesWebSocket = MockMessagesWebSocket();
    },
  ),

  _InitializationStep(
    'apis',
    (dp) {
      dp.postApi = PostApi(dp.dio, flavor.baseUrl);
      dp.messagesApi = MessagesApi(dp.dio, flavor.baseUrl);
      dp.chatsApi = ChatsApi(dp.dio, flavor.baseUrl);
    },
    callForTests: (dp) {
      dp.postApi = PostApi(dp.dio, flavor.baseUrl);
      dp.messagesApi = MockMessagesApi();
      dp.chatsApi = MockChatsApi();
    },
  ),

  _InitializationStep('repositories', (dp) {
    dp.filesRepository = FilesRepositoryImpl(filesApi: dp.filesApi);
    dp.postRepository = PostRepositoryImpl(postApi: dp.postApi);
    dp.connectionRepository = ConnectionRepositoryImpl(
      webSocket: dp.messagesWebSocket,
    );
    dp.messengerRepository = MessengerRepositoryImpl(
      webSocket: dp.messagesWebSocket,
      messagesApiDataSource: MessagesApiDataSourceImpl(messagesApi: dp.messagesApi),
      chatsApiDataSource: ChatsApiDataSourceImpl(chatsApi: dp.chatsApi),
      messagesLocalDataSource: dp.messagesLocalDataSource,
      chatsLocalDataSource: dp.chatsLocalDataSource,
      usersLocalDataSource: dp.usersLocalDataSource,
      combiner: CombineCacheAndApi(dp.messagesLocalDataSource),
    );
    dp.chatsRepository = ChatsRepositoryImpl(
      chatsApi: dp.chatsApi,
      chatsLocalDataSource: dp.chatsLocalDataSource,
    );
  }),

  _InitializationStep(('firebase'), (_) async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }),

  _InitializationStep('global_settings', (_) {
    VisibilityDetectorController.instance.updateInterval = const Duration(
      milliseconds: 100,
    );
  }),
];

class _InitializationStep {
  final String name;
  final Function(Dependencies) call;
  final Function(Dependencies)? callForTests;

  _InitializationStep(this.name, this.call, {this.callForTests});
}
