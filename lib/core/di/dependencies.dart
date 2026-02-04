import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kepleomax/core/auth/auth_controller.dart';
import 'package:kepleomax/core/data/auth_repository.dart';
import 'package:kepleomax/core/data/chats_repository.dart';
import 'package:kepleomax/core/data/connection_repository.dart';
import 'package:kepleomax/core/data/files_repository.dart';
import 'package:kepleomax/core/data/local_data_sources/chats_local_data_source.dart';
import 'package:kepleomax/core/data/local_data_sources/messages_local_data_source.dart';
import 'package:kepleomax/core/data/local_data_sources/users_local_data_source.dart';
import 'package:kepleomax/core/data/messenger_repository.dart';
import 'package:kepleomax/core/data/post_repository.dart';
import 'package:kepleomax/core/data/user_repository.dart';
import 'package:kepleomax/core/native/klm_method_channel.dart';
import 'package:kepleomax/core/network/apis/auth/auth_api.dart';
import 'package:kepleomax/core/network/apis/chats/chats_api.dart';
import 'package:kepleomax/core/network/apis/files/files_api.dart';
import 'package:kepleomax/core/network/apis/messages/messages_api.dart';
import 'package:kepleomax/core/network/apis/posts/post_api.dart';
import 'package:kepleomax/core/network/apis/profile/profile_api.dart';
import 'package:kepleomax/core/network/apis/user/user_api.dart';
import 'package:kepleomax/core/network/token_provider.dart';
import 'package:kepleomax/core/network/websockets/messages_web_socket.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class Dependencies {
  late final AuthController authController;
  late final TokenProvider tokenProvider;
  late final SharedPreferences sharedPreferences;
  late final FlutterSecureStorage secureStorage;
  late final PrettyDioLogger prettyDioLogger;
  late final KlmMethodChannel methodChannel;
  late final Database database;

  late final Dio dio;
  late final AuthApi authApi;
  late final UserApi userApi;
  late final ProfileApi profileApi;
  late final FilesApi filesApi;
  late final PostApi postApi;
  late final MessagesApi messagesApi;
  late final ChatsApi chatsApi;
  late final MessagesWebSocket messagesWebSocket;

  late final IUsersLocalDataSource usersLocalDataSource;
  late final IMessagesLocalDataSource messagesLocalDataSource;
  late final IChatsLocalDataSource chatsLocalDataSource;

  late final IAuthRepository authRepository;
  late final IUserRepository userRepository;
  late final IPostRepository postRepository;
  late final IFilesRepository filesRepository;
  late final IConnectionRepository connectionRepository;
  late final IMessengerRepository messengerRepository;
  late final IChatsRepository chatsRepository;

  Widget inject({required Widget child}) =>
      InheritedDependencies(dependencies: this, child: child);

  static Dependencies of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<InheritedDependencies>()!.dependencies;
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
