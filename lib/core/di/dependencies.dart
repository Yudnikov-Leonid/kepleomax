import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kepleomax/core/auth/auth_controller.dart';
import 'package:kepleomax/core/data/chats_repository.dart';
import 'package:kepleomax/core/data/files_repository.dart';
import 'package:kepleomax/core/data/messages_repository.dart';
import 'package:kepleomax/core/data/post_repository.dart';
import 'package:kepleomax/core/data/user_repository.dart';
import 'package:kepleomax/core/network/apis/auth/auth_api.dart';
import 'package:kepleomax/core/network/apis/chats/chats_api.dart';
import 'package:kepleomax/core/network/apis/files/files_api.dart';
import 'package:kepleomax/core/network/apis/messages/messages_api.dart';
import 'package:kepleomax/core/network/apis/posts/post_api.dart';
import 'package:kepleomax/core/network/apis/profile/profile_api.dart';
import 'package:kepleomax/core/network/apis/user/user_api.dart';
import 'package:kepleomax/core/network/token_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dependencies {
  late AuthController authController;
  late TokenProvider tokenProvider;
  late SharedPreferences sharedPreferences;
  late FlutterSecureStorage secureStorage;

  late UserRepository userRepository;
  late PostRepository postRepository;
  late FilesRepository filesRepository;
  late MessagesRepository messagesRepository;
  late ChatsRepository chatsRepository;

  late Dio dio;
  late AuthApi authApi;
  late UserApi userApi;
  late ProfileApi profileApi;
  late FilesApi filesApi;
  late PostApi postApi;
  late MessagesApi messagesApi;
  late ChatsApi chatsApi;

  Widget inject({required Widget child}) =>
      InheritedDependencies(dependencies: this, child: child);

  static Dependencies of(BuildContext context) => context
      .getInheritedWidgetOfExactType<InheritedDependencies>()!
      .dependencies;
}

class InheritedDependencies extends InheritedWidget {
  const InheritedDependencies({
    required this.dependencies,
    required super.child,
    super.key,
  });

  final Dependencies dependencies;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
