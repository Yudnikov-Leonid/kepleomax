import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kepleomax/core/auth/auth_controller.dart';
import 'package:kepleomax/core/auth/user_provider.dart';
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
import 'package:kepleomax/core/data/messenger_repository.dart';
import 'package:kepleomax/core/data/post_repository.dart';
import 'package:kepleomax/core/data/user_repository.dart';
import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/core/native/klm_method_channel.dart';
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
import 'package:kepleomax/firebase_options.dart';
import 'package:kepleomax/main.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';

Future<Dependencies> initializeDependencies() async {
  final dp = Dependencies();

  for (final step in _steps) {
    try {
      await step.call(dp);
    } catch (e, st) {
      logger.e('Error while initializing step ${step.name}: $e', stackTrace: st);
      rethrow;
    }
  }

  return dp;
}

List<_InitializationStep> _steps = [
  _InitializationStep(
    name: 'storages',
    call: (dependencies) async {
      dependencies.sharedPreferences = await SharedPreferences.getInstance();
      dependencies.secureStorage = const FlutterSecureStorage();
      dependencies.methodChannel = KlmMethodChannel();
      CachedNetworkImage.logLevel = CacheManagerLogLevel.verbose;
    },
  ),

  _InitializationStep(
    name: 'local_db',
    call: (dependencies) async {
      final db = await LocalDatabaseManager.getDatabase();
      dependencies.database = db;
      dependencies.usersLocalDataSource = UsersLocalDataSource(database: db);
      dependencies.messagesLocalDataSource = MessagesLocalDataSource(database: db);
      dependencies.chatsLocalDataSource = ChatsLocalDataSource(database: db);
    },
  ),

  /// TODO apis are here and in the 'apis, repositories' step, it's not good
  _InitializationStep(
    name: 'dio, authController',
    call: (dependencies) async {
      dependencies.prettyDioLogger = PrettyDioLogger(
        request: kDebugMode,
        requestHeader: kDebugMode,
        requestBody: kDebugMode,
        responseHeader: kDebugMode,
        responseBody: kDebugMode,
        error: kDebugMode,
        logPrint: (Object object) => debugPrint(object.toString(), wrapWidth: 1024),
      );

      final dio = Dio(BaseOptions(validateStatus: (_) => true));

      /// cause need prettyDioLogger here
      dependencies.tokenProvider = TokenProvider(
        prefs: dependencies.sharedPreferences,
        secureStorage: dependencies.secureStorage,
        dio: Dio(BaseOptions(validateStatus: (_) => true))
          ..interceptors.add(dependencies.prettyDioLogger),
      );

      /// cause need dio in authController and need authController in dio
      dependencies.authApi = AuthApi(dio, flavor.baseUrl);
      dependencies.authRepository = AuthRepository(authApi: dependencies.authApi);
      dependencies.userApi = UserApi(dio, flavor.baseUrl);
      dependencies.profileApi = ProfileApi(dio, flavor.baseUrl);
      dependencies.filesApi = FilesApi(dio, flavor.baseUrl);
      dependencies.userRepository = UserRepository(
        profileApi: dependencies.profileApi,
        filesApi: dependencies.filesApi,
        userApi: dependencies.userApi,
        usersLocalDataSource: dependencies.usersLocalDataSource,
      );
      final authController = AuthController(
        authRepository: dependencies.authRepository,
        userRepository: dependencies.userRepository,
        tokenProvider: dependencies.tokenProvider,
        userProvider: UserProvider(prefs: dependencies.sharedPreferences),
        prefs: dependencies.sharedPreferences,
      );
      await authController.init();
      dependencies.authController = authController;

      dio.interceptors.addAll([
        dependencies.prettyDioLogger,
        AuthInterceptor(
          tokenProvider: dependencies.tokenProvider,
          authController: dependencies.authController,
        ),
      ]);

      dependencies.dio = dio;
    },
  ),

  _InitializationStep(
    name: 'apis, repositories',
    call: (dependencies) {
      dependencies.postApi = PostApi(dependencies.dio, flavor.baseUrl);
      dependencies.messagesApi = MessagesApi(dependencies.dio, flavor.baseUrl);
      dependencies.chatsApi = ChatsApi(dependencies.dio, flavor.baseUrl);
      dependencies.messagesWebSocket = MessagesWebSocket(
        baseUrl: flavor.baseUrl,
        tokenProvider: dependencies.tokenProvider,
      );

      dependencies.filesRepository = FilesRepository(
        filesApi: dependencies.filesApi,
      );
      dependencies.postRepository = PostRepository(postApi: dependencies.postApi);
      dependencies.connectionRepository = ConnectionRepository(
        webSocket: dependencies.messagesWebSocket,
      );
      dependencies.messengerRepository = MessengerRepository(
        webSocket: dependencies.messagesWebSocket,
        messagesApi: MessagesApiDataSource(messagesApi: dependencies.messagesApi),
        chatsApi: ChatsApiDataSource(chatsApi: dependencies.chatsApi),
        messagesLocal: dependencies.messagesLocalDataSource,
        chatsLocal: dependencies.chatsLocalDataSource,
        usersLocal: dependencies.usersLocalDataSource,
      );
      dependencies.chatsRepository = ChatsRepository(
        chatsApi: dependencies.chatsApi,
        chatsLocalDataSource: dependencies.chatsLocalDataSource,
      );
    },
  ),

  _InitializationStep(
    name: ('firebase'),
    call: (dependencies) async {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    },
  ),

  _InitializationStep(
    name: 'global_settings',
    call: (_) {
      VisibilityDetectorController.instance.updateInterval = const Duration(
        milliseconds: 100,
      );
    },
  ),
];

class _InitializationStep {
  final String name;
  final Function(Dependencies) call;

  _InitializationStep({required this.name, required this.call});
}
