// dart format width=200

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kepleomax/core/data/data_sources/chats_api_data_sources.dart';
import 'package:kepleomax/core/data/data_sources/messages_api_data_sources.dart';
import 'package:kepleomax/core/data/local_data_sources/chats_local_data_source.dart';
import 'package:kepleomax/core/data/local_data_sources/messages_local_data_source.dart';
import 'package:kepleomax/core/data/local_data_sources/users_local_data_source.dart';
import 'package:kepleomax/core/data/messenger/messenger_repository.dart';
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

    List<MessageDto> generateGetMessagesFromCache(int from, int count, {int chatId = 0}) {
      final list = generateMessages(from, count, fromCache: true, chatId: chatId);
      getMessagesFromCacheMustReturn(list, chatId: chatId);
      return list;
    }

    List<MessageDto> generateGetMessages(int from, int count, {int chatId = 0}) {
      final list = generateMessages(from, count, chatId: chatId);
      getMessagesMustReturn(list, chatId: chatId);
      return list;
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
      await checkNextState([...apiMessages, if (apiMessages.length <= cacheMessages.length) ...cacheMessages.sublist(apiMessages.length)]);
    }

    /// loadMessages() tests -------------------------------------------------------
    test('load_messages_n_n_test', () async {
      final cacheMessages = generateGetMessagesFromCache(0, 15);
      final apiMessages = generateGetMessages(0, 15);

      repository.loadMessages(chatId: 0);
      await checkNextState(cacheMessages, maintainLoading: true, allMessagesLoaded: null);
      await checkNextState(apiMessages);
    });

    test('load_messages_n_out_test', () async {
      final cacheMessages = generateGetMessagesFromCache(0, 10);
      final apiMessages = generateGetMessages(0, 15);

      repository.loadMessages(chatId: 0);
      await checkNextState(cacheMessages, maintainLoading: true, allMessagesLoaded: null);
      await checkNextState(apiMessages);
    });

    test('load_messages_n_in_test', () async {
      final cacheMessages = generateGetMessagesFromCache(0, 20);
      final apiMessages = generateGetMessages(0, 15);

      repository.loadMessages(chatId: 0);
      await checkNextState(cacheMessages, maintainLoading: true, allMessagesLoaded: null);
      await checkNextState([...apiMessages, ...generateMessages(15, 5, fromCache: true)]);
    });

    test('load_messages_n_in_all_messages_loaded_test', () async {
      final cacheMessages = generateGetMessagesFromCache(0, 15);
      final apiMessages = generateGetMessages(0, 10);

      repository.loadMessages(chatId: 0);
      await checkNextState(cacheMessages, maintainLoading: true, allMessagesLoaded: null);
      await checkNextState([...apiMessages], allMessagesLoaded: true);
    });

    test('load_messages_out_n_test', () async {
      final cacheMessages = generateGetMessagesFromCache(5, 10);
      final apiMessages = generateGetMessages(0, 15);

      repository.loadMessages(chatId: 0);
      await checkNextState(cacheMessages, maintainLoading: true, allMessagesLoaded: null);
      await checkNextState(apiMessages);
    });

    /// not passing now
    test('load_messages_out_out_test', () async {
      final cacheMessages = generateGetMessagesFromCache(5, 5);
      final apiMessages = generateGetMessages(0, 15);

      repository.loadMessages(chatId: 0);
      await checkNextState(cacheMessages, maintainLoading: true, allMessagesLoaded: null);
      await checkNextState(apiMessages);
    });

    test('load_messages_out_in_test', () async {
      final cacheMessages = generateGetMessagesFromCache(5, 20);
      final apiMessages = generateGetMessages(0, 15);

      repository.loadMessages(chatId: 0);
      await checkNextState(cacheMessages, maintainLoading: true, allMessagesLoaded: null);
      await checkNextState([...apiMessages, ...generateMessages(15, 10, fromCache: true)]);
    });

    test('load_messages_out_in_all_messages_loaded_test', () async {
      final cacheMessages = generateGetMessagesFromCache(5, 10);
      final apiMessages = generateGetMessages(0, 10);

      repository.loadMessages(chatId: 0);
      await checkNextState(cacheMessages, maintainLoading: true, allMessagesLoaded: null);
      await checkNextState(apiMessages, allMessagesLoaded: true);
    });

    test('load_messages_in_n_test', () async {
      final cacheMessages = generateGetMessagesFromCache(0, 20);
      final apiMessages = generateGetMessages(5, 15);

      repository.loadMessages(chatId: 0);
      await checkNextState(cacheMessages, maintainLoading: true, allMessagesLoaded: null);
      await checkNextState(apiMessages);
    });

    test('load_messages_in_out_test', () async {
      final cacheMessages = generateGetMessagesFromCache(0, 15);
      final apiMessages = generateGetMessages(5, 15);

      repository.loadMessages(chatId: 0);
      await checkNextState(cacheMessages, maintainLoading: true, allMessagesLoaded: null);
      await checkNextState(apiMessages);
    });

    test('load_messages_in_in_test', () async {
      final cacheMessages = generateGetMessagesFromCache(0, 25);
      final apiMessages = generateGetMessages(5, 15);

      repository.loadMessages(chatId: 0);
      await checkNextState(cacheMessages, maintainLoading: true, allMessagesLoaded: null);
      await checkNextState([...apiMessages, ...generateMessages(20, 5, fromCache: true)]);
    });

    test('load_messages_in_in_all_messages_loaded_test', () async {
      final cacheMessages = generateGetMessagesFromCache(0, 25);
      final apiMessages = generateGetMessages(5, 10);

      repository.loadMessages(chatId: 0);
      await checkNextState(cacheMessages, maintainLoading: true, allMessagesLoaded: null);
      await checkNextState(apiMessages, allMessagesLoaded: true);
    });

    /// loadMoreMessages() tests ----------------------------------------------------
    test('load_more_messages_n_n_test', () async {
      final cacheMessages = generateMessages(0, 30, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      await setupFirstLoad(cacheMessages, apiMessages);

      final nextApiMessages = generateMessages(15, 15);
      getMessagesMustReturn(nextApiMessages, cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: 15);
      await checkNextState([...apiMessages, ...nextApiMessages]);
    });

    test('load_more_messages_n_n_conflict_test', () async {
      final cacheMessages = generateMessages(0, 30, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      await setupFirstLoad(cacheMessages, apiMessages);

      final nextApiMessages = [...generateMessages(15, 5), ...generateMessages(25, 10)];
      getMessagesMustReturn(nextApiMessages, cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: 15);
      await checkNextState([...apiMessages, ...nextApiMessages]);
    });

    test('load_more_messages_n_n_all_messages_loaded_test', () async {
      final cacheMessages = generateMessages(0, 20, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      await setupFirstLoad(cacheMessages, apiMessages);

      final nextApiMessages = generateMessages(15, 5);
      getMessagesMustReturn(nextApiMessages, cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: 15);
      await checkNextState([...apiMessages, ...nextApiMessages], allMessagesLoaded: true);
    });

    test('load_more_messages_n_out_test', () async {
      final cacheMessages = generateMessages(0, 30, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      await setupFirstLoad(cacheMessages, apiMessages);

      final nextApiMessages = generateMessages(15, 30);
      getMessagesMustReturn(nextApiMessages, limit: 30, cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: null);
      await checkNextState([...apiMessages, ...nextApiMessages]);
    });

    test('load_more_messages_n_out_conflict_test', () async {
      final cacheMessages = generateMessages(0, 30, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      await setupFirstLoad(cacheMessages, apiMessages);

      final nextApiMessages = [...generateMessages(15, 15), ...generateMessages(50, 15)];
      getMessagesMustReturn(nextApiMessages, limit: 30, cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: null);
      await checkNextState([...apiMessages, ...nextApiMessages]);
    });

    test('load_more_messages_n_out_all_messages_loaded_test', () async {
      final cacheMessages = generateMessages(0, 25, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      await setupFirstLoad(cacheMessages, apiMessages);

      final nextApiMessages = generateMessages(15, 15);
      getMessagesMustReturn(nextApiMessages, limit: 25, cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: null);
      await checkNextState([...apiMessages, ...nextApiMessages], allMessagesLoaded: true);
    });

    test('load_more_messages_n_in_test', () async {
      final cacheMessages = generateMessages(0, 45, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      await setupFirstLoad(cacheMessages, apiMessages);

      final nextApiMessages = generateMessages(15, 15);
      getMessagesMustReturn(nextApiMessages, limit: 15, cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: 15);
      await checkNextState([...apiMessages, ...nextApiMessages, ...generateMessages(30, 15, fromCache: true)]);
    });

    test('load_more_messages_n_in_conflict_test', () async {
      final cacheMessages = generateMessages(0, 45, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      await setupFirstLoad(cacheMessages, apiMessages);

      final nextApiMessages = [...generateMessages(15, 10), ...generateMessages(30, 5)];
      getMessagesMustReturn(nextApiMessages, limit: 15, cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: 15);
      await checkNextState([...apiMessages, ...nextApiMessages, ...generateMessages(35, 10, fromCache: true)]);
    });

    /// not passing now
    test('load_more_messages_n_in_all_messages_loaded_test', () async {
      final cacheMessages = generateMessages(0, 45, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      await setupFirstLoad(cacheMessages, apiMessages);

      final nextApiMessages = generateMessages(15, 10);
      getMessagesMustReturn(nextApiMessages, limit: 15, cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: 15);
      await checkNextState([...apiMessages, ...nextApiMessages], allMessagesLoaded: true);
    });

    test('load_more_messages_without_cache_test', () async {
      final cacheMessages = generateMessages(0, 15, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      await setupFirstLoad(cacheMessages, apiMessages);

      final nextApiMessages = generateMessages(15, 15);
      getMessagesMustReturn(nextApiMessages, limit: 15, cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: 15);
      await checkNextState([...apiMessages, ...nextApiMessages]);
    });

    test('load_more_messages_without_cache_all_messages_loaded_test', () async {
      final cacheMessages = generateMessages(0, 15, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      await setupFirstLoad(cacheMessages, apiMessages);

      final nextApiMessages = generateMessages(15, 10);
      getMessagesMustReturn(nextApiMessages, limit: 15, cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: 15);
      await checkNextState([...apiMessages, ...nextApiMessages], allMessagesLoaded: true);
    });

    test('load_more_messages_n_out_gap_conflict_test', () async {
      final cacheMessages = generateMessages(0, 15, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      await setupFirstLoad(cacheMessages, apiMessages);

      final nextApiMessages = generateMessages(20, 15);
      getMessagesMustReturn(nextApiMessages, limit: 15, cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: 15);
      await checkNextState([...apiMessages, ...nextApiMessages]);
    });

    /// now passing now
    test('load_more_messages_n_out_gap_conflict_all_messages_loaded_test', () async {
      final cacheMessages = generateMessages(0, 10, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      await setupFirstLoad(cacheMessages, apiMessages);

      final nextApiMessages = generateMessages(20, 10);
      getMessagesMustReturn(nextApiMessages, limit: 15, cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: 15);
      await checkNextState([...apiMessages, ...nextApiMessages], allMessagesLoaded: true);
    });

    test('load_more_messages_n_n_gap_conflict_test', () async {
      final cacheMessages = generateMessages(0, 35, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      await setupFirstLoad(cacheMessages, apiMessages);

      final nextApiMessages = generateMessages(20, 15);
      getMessagesMustReturn(nextApiMessages, limit: 15, cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: 15);
      await checkNextState([...apiMessages, ...nextApiMessages]);
    });

    test('load_more_messages_n_n_gap_conflict_all_messages_loaded_test', () async {
      final cacheMessages = generateMessages(0, 15, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      await setupFirstLoad(cacheMessages, apiMessages);

      final nextApiMessages = generateMessages(20, 10);
      getMessagesMustReturn(nextApiMessages, limit: 15, cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: 15);
      await checkNextState([...apiMessages, ...nextApiMessages], allMessagesLoaded: true);
    });

    test('load_more_messages_n_in_gap_conflict_test', () async {
      final cacheMessages = generateMessages(0, 45, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      await setupFirstLoad(cacheMessages, apiMessages);

      final nextApiMessages = generateMessages(20, 15);
      getMessagesMustReturn(nextApiMessages, limit: 15, cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: 15);
      await checkNextState([...apiMessages, ...nextApiMessages, ...generateMessages(35, 10, fromCache: true)]);
    });

    /// not passing now
    test('load_more_messages_n_in_gap_conflict_all_messages_loaded_test', () async {
      final cacheMessages = generateMessages(0, 45, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      await setupFirstLoad(cacheMessages, apiMessages);

      final nextApiMessages = generateMessages(20, 10);
      getMessagesMustReturn(nextApiMessages, limit: 15, cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: 15);
      await checkNextState([...apiMessages, ...nextApiMessages], allMessagesLoaded: true);
    });

    /// if messageId == null -> must load all cached messages + 15 more
    /// if messageId != null -> must load all cached messages before messageId and messageId + 15
    test('load_more_messages_to_message_id_test', () async {
      final cacheMessages = generateMessages(0, 45, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      await setupFirstLoad(cacheMessages, apiMessages);

      final nextApiMessages = generateMessages(15, 25);
      getMessagesMustReturn(nextApiMessages, limit: 25, cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: 25);
      await checkNextState([...apiMessages, ...nextApiMessages, ...generateMessages(40, 5, fromCache: true)]);
    });

    /// not passing now
    test('load_more_messages_to_message_id_all_messages_loaded_test', () async {
      final cacheMessages = generateMessages(0, 45, fromCache: true);
      final apiMessages = generateMessages(0, 15);
      await setupFirstLoad(cacheMessages, apiMessages);

      final nextApiMessages = generateMessages(15, 20);
      getMessagesMustReturn(nextApiMessages, limit: 25, cursor: 14);
      repository.loadMoreMessages(chatId: 0, toMessageId: 25);
      await checkNextState([...apiMessages, ...nextApiMessages], allMessagesLoaded: true);
    });

    /// TODO local_db_tests

    /// old style tests
    // test('load_more_messages_conflict_with_cache_1_test', () async {
    //   final cacheMessages = generateMessages(0, 30, fromCache: true);
    //   final apiMessages = generateMessages(0, 15);
    //   await setupFirstLoad(cacheMessages, apiMessages);
    //
    //   final nextApiMessages = [...generateMessages(15, 5), ...generateMessages(25, 10)];
    //   getMessagesMustReturn(nextApiMessages, cursor: 14);
    //   repository.loadMoreMessages(chatId: 0, toMessageId: 15);
    //   await checkNextState([...apiMessages, ...nextApiMessages]);
    // });
    //
    // test('load_more_messages_conflict_with_cache_2_test', () async {
    //   final cacheMessages = generateMessages(0, 30, fromCache: true);
    //   final apiMessages = generateMessages(0, 15);
    //   await setupFirstLoad(cacheMessages, apiMessages);
    //
    //   final nextApiMessages = generateMessages(20, 15);
    //   getMessagesMustReturn(nextApiMessages, cursor: 14);
    //   repository.loadMoreMessages(chatId: 0, toMessageId: 15);
    //   await checkNextState([...apiMessages, ...nextApiMessages]);
    // });
    //
    // test('load_more_messages_conflict_with_cache_3_test', () async {
    //   final cacheMessages = generateMessages(0, 30, fromCache: true);
    //   final apiMessages = generateMessages(0, 15);
    //   await setupFirstLoad(cacheMessages, apiMessages);
    //
    //   final nextApiMessages = [...generateMessages(15, 1), ...generateMessages(20, 14)];
    //   getMessagesMustReturn(nextApiMessages, cursor: 14);
    //   repository.loadMoreMessages(chatId: 0, toMessageId: 15);
    //   await checkNextState([...apiMessages, ...nextApiMessages]);
    // });
    //
    // test('load_more_messages_with_toMessageId_test', () async {
    //   final cacheMessages = generateMessages(0, 30, fromCache: true);
    //   final apiMessages = generateMessages(0, 15);
    //   await setupFirstLoad(cacheMessages, apiMessages);
    //
    //   final nextApiMessages = generateMessages(15, 20);
    //   getMessagesMustReturn(nextApiMessages, limit: 20, cursor: 14);
    //   repository.loadMoreMessages(chatId: 0, toMessageId: 20);
    //   await checkNextState([...apiMessages, ...nextApiMessages]);
    // });
    //
    // test('load_more_messages_without_toMessageId_test', () async {
    //   final cacheMessages = generateMessages(0, 30, fromCache: true);
    //   final apiMessages = generateMessages(0, 15);
    //   await setupFirstLoad(cacheMessages, apiMessages);
    //
    //   /// limit: 30 cause toMessageId: null - means we on the top of the page, it's paging not from cache
    //   /// so it should load all cachedMessages (15) and 15 more new messages
    //   final nextApiMessages = generateMessages(15, 20);
    //   getMessagesMustReturn(nextApiMessages, limit: 30, cursor: 14);
    //   repository.loadMoreMessages(chatId: 0, toMessageId: null);
    //   await checkNextState([...apiMessages, ...nextApiMessages], allMessagesLoaded: true);
    // });
  });
}
