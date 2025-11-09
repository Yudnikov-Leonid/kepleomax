import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kepleomax/core/auth/auth_controller.dart';
import 'package:kepleomax/core/auth/user_provider.dart';
import 'package:kepleomax/core/data/user_repository.dart';
import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/core/network/apis/auth/auth_api.dart';
import 'package:kepleomax/core/network/apis/profile/profile_api.dart';
import 'package:kepleomax/core/network/apis/user/user_api.dart';
import 'package:kepleomax/core/network/middlewares/auth_interceptor.dart';
import 'package:kepleomax/core/network/token_provider.dart';
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
      dependencies.secureStorage = FlutterSecureStorage();
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

      // cause need dio here
      dependencies.authApi = AuthApi(dio, flavor.baseUrl);
      dependencies.userApi = UserApi(dio, flavor.baseUrl);
      final authController = AuthController(
        authApi: dependencies.authApi,
        userApi: dependencies.userApi,
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
  
  _InitializationStep(name: 'userRepository', call: (dependencies) {
    dependencies.profileApi = ProfileApi(dependencies.dio, flavor.baseUrl);
    dependencies.userRepository = UserRepository(profileApi: dependencies.profileApi);
  })
];

class _InitializationStep {
  final String name;
  final Function(Dependencies) call;

  _InitializationStep({required this.name, required this.call});
}
