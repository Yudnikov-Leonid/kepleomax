import 'package:kepleomax/core/data/data_sources/chats_api_data_sources.dart';
import 'package:kepleomax/core/data/data_sources/messages_api_data_sources.dart';
import 'package:kepleomax/core/data/local_data_sources/chats_local_data_source.dart';
import 'package:kepleomax/core/data/local_data_sources/users_local_data_source.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  ChatsApiDataSource,
  MessagesApiDataSource,
  ChatsLocalDataSource,
  UsersLocalDataSource,
])
abstract class _MockitoMocks {}
