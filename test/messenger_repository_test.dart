// dart format width=200

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kepleomax/core/data/data_sources/chats_api_data_sources.dart';
import 'package:kepleomax/core/data/data_sources/messages_api_data_sources.dart';
import 'package:kepleomax/core/data/local_data_sources/chats_local_data_source.dart';
import 'package:kepleomax/core/data/local_data_sources/messages_local_data_source.dart';
import 'package:kepleomax/core/data/local_data_sources/users_local_data_source.dart';
import 'package:kepleomax/core/data/messenger_repository.dart';
import 'package:kepleomax/core/data/models/messages_collection.dart';
import 'package:kepleomax/core/mocks/mock_messages_web_socket.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'messenger_repository_test.mocks.dart';

@GenerateMocks([ChatsApiDataSource, MessagesApiDataSource, MessagesLocalDataSource, ChatsLocalDataSource, UsersLocalDataSource])
void main() {
  group('messenger_repository_test', () {
    late MessengerRepository repository;
    late StreamIterator<MessagesCollection> iterator;
    late MockMessagesWebSocket ws;
    late MockMessagesLocalDataSource messagesLocal;
    late MockMessagesApiDataSource messagesApi;

    setUp(() {
      ws = MockMessagesWebSocket();
      messagesLocal = MockMessagesLocalDataSource();
      messagesApi = MockMessagesApiDataSource();

      repository = MessengerRepositoryImpl(
        webSocket: ws,
        chatsApiDataSource: MockChatsApiDataSource(),
        messagesApiDataSource: messagesApi,
        messagesLocalDataSource: messagesLocal,
        chatsLocalDataSource: MockChatsLocalDataSource(),
        usersLocalDataSource: MockUsersLocalDataSource(),
      );

      iterator = StreamIterator(repository.messagesUpdatesStream);
    });

    List<MessageDto> generateMessages(int from, int count, {int chatId = 0, bool fromCache = false}) => List.generate(
      count,
      (i) => MessageDto(
        id: i + from,
        chatId: chatId,
        senderId: 1,
        isCurrentUser: false,
        message: 'MSG_${fromCache ? 'CACHE' : 'API'}_${i + from}',
        isRead: true,
        createdAt: 800,
        editedAt: null,
        fromCache: fromCache,
      ),
    );

    void getMessagesFromCacheMustReturn(List<MessageDto> messages, {int chatId = 0}) {
      when(messagesLocal.getMessagesByChatId(chatId)).thenAnswer((_) async => messages);
    }

    void getMessagesMustReturn(List<MessageDto> messages, {int chatId = 0, int limit = 15, int? cursor}) {
      when(messagesApi.getMessages(chatId: chatId, limit: limit, cursor: cursor)).thenAnswer((_) async => messages);
    }

    Future<void> checkNextState(List<MessageDto> messages, {bool maintainLoading = false, bool? allMessagesLoaded = false}) async {
      await iterator.moveNext();
      expect(
        iterator.current,
        MessagesCollection(chatId: 0, messages: messages.map(Message.fromDto).toList(), maintainLoading: maintainLoading, allMessagesLoaded: allMessagesLoaded),
        reason:
            '\nExpected messages (id, fromCache): ${messages.map((m) => '(${m.id}, ${m.fromCache})').toList()}\nActual messages (id, fromCache): ${iterator.current.messages.map((m) => '(${m.id}, ${m.fromCache})').toList()}',
      );
    }

    Future<void> setupFirstLoad(List<MessageDto> cacheMessages, List<MessageDto> apiMessages) async {
      getMessagesFromCacheMustReturn(cacheMessages);
      getMessagesMustReturn(apiMessages);

      repository.loadMessages(chatId: 0);
      await checkNextState(cacheMessages, maintainLoading: true, allMessagesLoaded: null);
      await checkNextState([...apiMessages, ...cacheMessages.sublist(apiMessages.length)]);
    }

    test('load_messages_test', () async {
      final cacheMessages = generateMessages(0, 5, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      getMessagesFromCacheMustReturn(cacheMessages);
      getMessagesMustReturn(apiMessages);

      /// load messages, check cache, api
      repository.loadMessages(chatId: 0);
      await checkNextState(cacheMessages, maintainLoading: true, allMessagesLoaded: null);
      await checkNextState(apiMessages);
    });

    test('load_more_messages_test', () async {
      final cacheMessages = generateMessages(0, 15, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      getMessagesFromCacheMustReturn(cacheMessages);
      getMessagesMustReturn(apiMessages);

      /// load messages, skip cache, check from api
      repository.loadMessages(chatId: 0);
      await iterator.moveNext();
      await checkNextState(apiMessages);

      /// call loadMoreMessages, check
      getMessagesMustReturn(generateMessages(15, 15), cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: null);
      await checkNextState([...apiMessages, ...generateMessages(15, 15)]);
    });

    test('all_messages_loaded_test', () async {
      final cacheMessages = generateMessages(0, 15, fromCache: true);
      final apiMessages = generateMessages(0, 13);
      getMessagesFromCacheMustReturn(cacheMessages);
      getMessagesMustReturn(apiMessages);

      /// load messages, skip cache, check from api
      repository.loadMessages(chatId: 0);
      await iterator.moveNext();
      await checkNextState(apiMessages, allMessagesLoaded: true);
    });

    test('load_messages_conflict_with_cache_1_test', () async {
      final cacheMessages = generateMessages(0, 15, fromCache: true);
      final apiMessages = [...generateMessages(0, 5), ...generateMessages(7, 10)];
      getMessagesFromCacheMustReturn(cacheMessages);
      getMessagesMustReturn(apiMessages);

      /// check
      repository.loadMessages(chatId: 0);
      await iterator.moveNext();
      await checkNextState(apiMessages);

      /// check loadMore
      getMessagesMustReturn(generateMessages(17, 15), cursor: 16);
      repository.loadMoreMessages(chatId: 0, toMessageId: null);
      await checkNextState([...apiMessages, ...generateMessages(17, 15)]);
    });

    test('load_messages_conflict_with_cache_2_test', () async {
      final cacheMessages = generateMessages(0, 15, fromCache: true);
      final apiMessages = generateMessages(1, 15);
      getMessagesFromCacheMustReturn(cacheMessages);
      getMessagesMustReturn(apiMessages);

      /// check
      repository.loadMessages(chatId: 0);
      await iterator.moveNext();
      await checkNextState(apiMessages);
    });

    test('load_messages_conflict_with_cache_3_test', () async {
      final cacheMessages = generateMessages(0, 15, fromCache: true);
      final apiMessages = <MessageDto>[];
      getMessagesFromCacheMustReturn(cacheMessages);
      getMessagesMustReturn(apiMessages);

      /// check
      repository.loadMessages(chatId: 0);
      await iterator.moveNext();
      await checkNextState(apiMessages, allMessagesLoaded: true);
    });

    test('load_messages_conflict_with_cache_4_test', () async {
      final cacheMessages = generateMessages(0, 45, fromCache: true);
      final apiMessages = generateMessages(15, 15);
      getMessagesFromCacheMustReturn(cacheMessages);
      getMessagesMustReturn(apiMessages);

      /// check
      repository.loadMessages(chatId: 0);
      await iterator.moveNext();
      await checkNextState([...apiMessages, ...generateMessages(30, 15, fromCache: true)]);
    });

    test('load_messages_conflict_with_cache_5_test', () async {
      final cacheMessages = generateMessages(0, 45, fromCache: true);
      final apiMessages = generateMessages(15, 14);
      getMessagesFromCacheMustReturn(cacheMessages);
      getMessagesMustReturn(apiMessages);

      /// check
      repository.loadMessages(chatId: 0);
      await iterator.moveNext();
      await checkNextState([...apiMessages], allMessagesLoaded: true);
    });

    test('load_more_messages_conflict_with_cache_1_test', () async {
      final cacheMessages = generateMessages(0, 30, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      await setupFirstLoad(cacheMessages, apiMessages);

      final nextApiMessages = [...generateMessages(15, 5), ...generateMessages(25, 10)];
      getMessagesMustReturn(nextApiMessages, cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: 15);
      await checkNextState([...apiMessages, ...nextApiMessages]);
    });

    /// not passing now
    test('load_more_messages_conflict_with_cache_2_test', () async {
      final cacheMessages = generateMessages(0, 30, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      await setupFirstLoad(cacheMessages, apiMessages);

      final nextApiMessages = generateMessages(20, 15);
      getMessagesMustReturn(nextApiMessages, cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: 15);
      await checkNextState([...apiMessages, ...nextApiMessages]);
    });

    test('load_more_messages_conflict_with_cache_3_test', () async {
      final cacheMessages = generateMessages(0, 30, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      await setupFirstLoad(cacheMessages, apiMessages);

      final nextApiMessages = [...generateMessages(15, 1), ...generateMessages(20, 14)];
      getMessagesMustReturn(nextApiMessages, cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: 15);
      await checkNextState([...apiMessages, ...nextApiMessages]);
    });

    test('load_more_messages_with_toMessageId_test', () async {
      final cacheMessages = generateMessages(0, 30, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      await setupFirstLoad(cacheMessages, apiMessages);

      final nextApiMessages = generateMessages(15, 20);
      getMessagesMustReturn(nextApiMessages, limit: 20, cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: 20);
      await checkNextState([...apiMessages, ...nextApiMessages]);
    });

    test('load_more_messages_without_toMessageId_test', () async {
      final cacheMessages = generateMessages(0, 30, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      await setupFirstLoad(cacheMessages, apiMessages);

      /// limit: 30 cause toMessageId: null - means we on the top of the page, it's paging not from cache
      /// so it should load all cachedMessages (15) and 15 more new messages
      final nextApiMessages = generateMessages(15, 20);
      getMessagesMustReturn(nextApiMessages, limit: 30, cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: null);
      await checkNextState([...apiMessages, ...nextApiMessages], allMessagesLoaded: true);
    });
  });
}
