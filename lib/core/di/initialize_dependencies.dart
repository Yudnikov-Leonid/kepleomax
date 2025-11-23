import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kepleomax/core/auth/auth_controller.dart';
import 'package:kepleomax/core/auth/user_provider.dart';
import 'package:kepleomax/core/data/auth_repository.dart';
import 'package:kepleomax/core/data/chats_repository.dart';
import 'package:kepleomax/core/data/files_repository.dart';
import 'package:kepleomax/core/data/messages_repository.dart';
import 'package:kepleomax/core/data/post_repository.dart';
import 'package:kepleomax/core/data/user_repository.dart';
import 'package:kepleomax/core/di/dependencies.dart';
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
import 'package:kepleomax/core/notifications/notifications_service.dart';
import 'package:kepleomax/firebase_options.dart';
import 'package:kepleomax/main.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      dependencies.tokenProvider = TokenProvider(
        prefs: dependencies.sharedPreferences,
        secureStorage: dependencies.secureStorage,
      );
    },
  ),

  _InitializationStep(
    name: 'dio, authController',
    call: (dependencies) async {
      final dio = Dio(BaseOptions(validateStatus: (_) => true));

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
      );
      final authController = AuthController(
        authRepository: dependencies.authRepository,
        userRepository: dependencies.userRepository,
        tokenProvider: dependencies.tokenProvider,
        userProvider: UserProvider(prefs: dependencies.sharedPreferences),
      );
      await authController.init();
      dependencies.authController = authController;

      dio.interceptors.addAll([
        PrettyDioLogger(
          request: kDebugMode,
          requestHeader: kDebugMode,
          requestBody: kDebugMode,
          responseHeader: kDebugMode,
          responseBody: kDebugMode,
          error: kDebugMode,
          logPrint: (Object object) =>
              debugPrint(object.toString(), wrapWidth: 1024),
        ),
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
      dependencies.messagesWebSocket = MessagesWebSocket(baseUrl: flavor.baseUrl, tokenProvider: dependencies.tokenProvider);

      dependencies.filesRepository = FilesRepository(
        filesApi: dependencies.filesApi,
      );
      dependencies.postRepository = PostRepository(postApi: dependencies.postApi);
      dependencies.messagesRepository = MessagesRepository(
        messagesApi: dependencies.messagesApi,
        messagesWebSocket: dependencies.messagesWebSocket
      );
      dependencies.chatsRepository = ChatsRepository(
        chatsApi: dependencies.chatsApi,
      );
    },
  ),

  _InitializationStep(
    name: ('firebase'),
    call: (dependencies) async {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

      final fcmToken = await FirebaseMessaging.instance.getToken();
      print('fcmToken: $fcmToken');

      NotificationService.instance.init();
    },
  ),
];

class _InitializationStep {
  final String name;
  final Function(Dependencies) call;

  _InitializationStep({required this.name, required this.call});
}
