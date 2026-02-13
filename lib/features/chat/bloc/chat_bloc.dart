import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/data/chats_repository.dart';
import 'package:kepleomax/core/data/connection_repository.dart';
import 'package:kepleomax/core/data/messenger_repository.dart';
import 'package:kepleomax/core/data/models/messages_collection.dart';
import 'package:kepleomax/core/flavor.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/presentation/user_error_message.dart';
import 'package:rxdart/rxdart.dart';
import 'package:kepleomax/core/logger.dart';

import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final MessengerRepository _messengerRepository;
  final ChatsRepository _chatsRepository;
  final ConnectionRepository _connectionRepository;
  late ChatData _data = ChatData.initial();
  late StreamSubscription _messagesUpdatesSub;
  late StreamSubscription _connectionStateSub;
  late StreamSubscription _chatUpdatesSub;

  ChatBloc({
    required MessengerRepository messengerRepository,
    required ChatsRepository chatsRepository,
    required ConnectionRepository connectionRepository,
    required int chatId,
  }) : _messengerRepository = messengerRepository,
       _chatsRepository = chatsRepository,
       _connectionRepository = connectionRepository,
       super(ChatStateBase.initial()) {
    _chatUpdatesSub = _messengerRepository.chatsUpdatesStream.listen((newList) {
      final currentChat = newList.chats.where((e) => e.id == chatId).firstOrNull;
      if (currentChat != null) {
        add(ChatEventChangeUnreadCount(newCount: currentChat.unreadCount));
      }
    }, cancelOnError: false);
    _connectionStateSub = _connectionRepository.connectionStateStream.listen(
      (isConnected) => add(ChatEventConnectingChanged(isConnected)),
      cancelOnError: false,
    );
    _messagesUpdatesSub = _messengerRepository.messagesUpdatesStream.listen(
      (data) {
        add(ChatEventEmitMessages(data: data));
      },
      onError: (e, st) {
        add(ChatEventEmitError(error: e, stackTrace: st));
      },
      cancelOnError: false,
    );

    /// TODO why there is ChatEventReadMessagesBeforeTime here?
    on<ChatEvent>(
      (event, emit) => switch (event) {
        ChatEventLoad event => _onLoad(event, emit),
        ChatEventReadMessagesBeforeTime event => _onReadMessagesBeforeTime(
          event,
          emit,
        ),
        _ => () {},
      },
      transformer: sequential(),
    );
    on<ChatEventLoadMore>(
      _onLoadMore,
      transformer: (events, mapper) => events
          .throttle(
            (_) => Stream.periodic(const Duration(milliseconds: 500)).take(1),
            trailing: true,
          )
          .exhaustMap(mapper),
    );
    on<ChatEventInit>(_onInit);
    on<ChatEventSendMessage>(_onSendMessage);
    on<ChatEventDeleteMessage>(_onDeleteMessage);
    on<ChatEventReadAllMessages>(_onReadAllMessages);
    on<ChatEventConnectingChanged>(_onConnectionChanged);
    on<ChatEventChangeUnreadCount>(_onChangeUnreadCount);
    on<ChatEventEmitMessages>(_onEmitMessages);
    on<ChatEventEmitError>(_onEmitError);
  }

  void _onInit(ChatEventInit event, Emitter<ChatState> emit) {
    _data = _data.copyWith(chatId: event.chatId, otherUser: event.otherUser);
    emit(ChatStateBase(data: _data));

    add(
      ChatEventLoad(
        chatId: event.chatId,
        otherUser: event.otherUser,
        withCache: true,
      ),
    );
    // if (_connectionRepository.isConnected) {
    //   add(ChatEventLoad(chatId: event.chatId, otherUser: event.otherUser));
    // }
  }

  /// cause can be called on init and on connect at the same time
  int _lastTimeLoadWasCalled = 0;

  void _onLoad(ChatEventLoad event, Emitter<ChatState> emit) async {
    /// TODO make better flavor.isTesting
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - 1000 < _lastTimeLoadWasCalled && !flavor.isTesting) {
      return;
    }
    _lastTimeLoadWasCalled = now;

    /// should set isConnected cause it can be called at init bloc
    _data = _data.copyWith(
      isConnected: _connectionRepository.isConnected,
      isLoading: true,
      isAllMessagesLoaded: false,
    );
    emit(ChatStateBase(data: _data));

    try {
      int chatId = event.chatId;

      /// either chatId == -1 and we have otherUser, or otherUser == null and we have chatId
      if (chatId == -1) {
        /// if someday the logic will be changed so chatId will be able to change, this is a potential bug spot
        /// cause if we have cache, we don't check actual data from api BUT now everytime when chats are
        /// loaded, cache be cleared and new chats are stored there. So if chatId will be changed
        /// cache will be updated after next LoadChatsEvent() in chats_bloc
        final cachedChat = await _chatsRepository.getChatWithUserFromCache(
          event.otherUser!.id,
        );
        if (cachedChat != null) {
          chatId = cachedChat.id;
        } else {
          final chat = await _chatsRepository.getChatWithUser(event.otherUser!.id);
          chatId = chat?.id ?? -1;
        }

        if (chatId == -1) {
          /// it's new chat with new user
          _data = _data.copyWith(chatId: -1, isLoading: false, messages: []);
          emit(ChatStateBase(data: _data));
          return;
        } else {
          /// it's existing chat with otherUser, but was opened not from chat page
          _data = _data.copyWith(chatId: chatId);
        }
      } else if (event.otherUser == null) {
        /// chat was opened from notification
        final chat = await _chatsRepository.getChatWithId(event.chatId);
        _data = _data.copyWith(otherUser: chat!.otherUser);
      }

      // print(
      //   'MyLog loadMessages with chatId: $chatId, withCache: ${event.withCache}',
      // );
      await _messengerRepository.loadMessages(
        chatId: chatId,
        withCache: event.withCache,
      );
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(ChatStateMessage(message: e.userErrorMessage, isError: true));
      _data = _data.copyWith(isLoading: false);
      emit(ChatStateBase(data: _data));
    }
  }

  // List<Message> _withUnreadMessages(List<Message> messages) {
  //   if (messages.isEmpty) return [];
  //
  //   var newList = <Message>[];
  //   bool isStopMessageFound = false;
  //   for (int i = 0; i < messages.length; i++) {
  //     if (messages[i].isCurrentUser) {
  //       /// message of current user, unreadMessagesLine can't be above, so end the loop
  //       newList.addAll(messages.sublist(i));
  //       isStopMessageFound = true;
  //       break;
  //     }
  //     if (messages[i].isRead) {
  //       /// message of not current user is read. If it's first message, then
  //       /// don't need the line. If it's not the first one, then add the line
  //       if (i != 0) {
  //         newList.add(Message.unreadMessages());
  //       }
  //       newList.addAll(messages.sublist(i));
  //       isStopMessageFound = true;
  //       break;
  //     }
  //
  //     /// message of not current user that unread, go to the next one
  //     newList.add(messages[i]);
  //   }
  //   if (!isStopMessageFound) {
  //     /// means this is new chat with unread messages from other user
  //     newList.add(Message.unreadMessages());
  //   }
  //
  //   return newList;
  // }

  void _onReadMessagesBeforeTime(
    ChatEventReadMessagesBeforeTime event,
    Emitter<ChatState> emit,
  ) {
    if (_data.isLoading || !_data.isConnected) return;
    _connectionRepository.readMessageBeforeTime(
      chatId: _data.chatId,
      time: event.time,
    );
  }

  void _onReadAllMessages(ChatEventReadAllMessages event, Emitter<ChatState> emit) {
    _connectionRepository.readAllMessages(chatId: _data.chatId);
  }

  void _onSendMessage(ChatEventSendMessage event, Emitter<ChatState> emit) {
    _connectionRepository.sendMessage(
      messageBody: event.messageBody,
      recipientId: _data.otherUser!.id,
    );
  }

  void _onDeleteMessage(ChatEventDeleteMessage event, Emitter<ChatState> emit) {
    _connectionRepository.deleteMessage(messageId: event.messageId);
  }

  void _onLoadMore(ChatEventLoadMore event, Emitter<ChatState> emit) async {
    if (_data.isAllMessagesLoaded || _data.isLoading) return;

    try {
      await _messengerRepository.loadMoreMessages(
        chatId: _data.chatId,
        toMessageId: event.toMessageId,
      );
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(ChatStateMessage(message: e.userErrorMessage, isError: true));
      _data = _data.copyWith(isAllMessagesLoaded: true);
      emit(ChatStateBase(data: _data));
    }
  }

  void _onConnectionChanged(
    ChatEventConnectingChanged event,
    Emitter<ChatState> emit,
  ) {
    _data = _data.copyWith(isConnected: event.isConnected);
    emit(ChatStateBase(data: _data));

    if (event.isConnected) {
      if (_data.chatId != -1 || _data.otherUser != null) {
        add(
          ChatEventLoad(
            chatId: _data.chatId,
            otherUser: _data.otherUser,
            withCache: true,
          ),
        );
      }
    }
  }

  void _onChangeUnreadCount(
    ChatEventChangeUnreadCount event,
    Emitter<ChatState> emit,
  ) {
    _data = _data.copyWith(unreadCount: event.newCount);
    emit(ChatStateBase(data: _data));
  }

  void _onEmitMessages(ChatEventEmitMessages event, Emitter<ChatState> emit) {
    final messages = event.data.messages.toList(growable: false);
    final newMessages = <Message>[];
    for (int i = 0; i < messages.length; i++) {
      newMessages.add(messages[i]);
      final createdAt1 = messages[i].createdAt;
      final createdAt2 = messages.elementAtOrNull(i + 1)?.createdAt;
      if (createdAt2 == null ||
          createdAt1.day > createdAt2.day ||
          createdAt1.month > createdAt2.month ||
          createdAt1.year > createdAt2.year) {
        newMessages.add(Message.date(createdAt1));
      }
    }
    _data = _data.copyWith(
      messages: newMessages,
      isLoading: event.data.maintainLoading,
    );
    if (event.data.allMessagesLoaded != null) {
      _data = _data.copyWith(isAllMessagesLoaded: event.data.allMessagesLoaded!);
    }
    emit(ChatStateBase(data: _data));
  }

  void _onEmitError(ChatEventEmitError event, Emitter<ChatState> emit) {
    final e = event.error;
    final st = event.stackTrace;
    logger.e(e, stackTrace: st);
    emit(ChatStateMessage(message: e.userErrorMessage, isError: true));
    emit(ChatStateBase(data: _data));
  }

  @override
  Future<void> close() {
    _messagesUpdatesSub.cancel();
    _connectionStateSub.cancel();
    _chatUpdatesSub.cancel();
    return super.close();
  }
}

/// events
abstract class ChatEvent {}

class ChatEventInit implements ChatEvent {
  final int chatId;
  final User? otherUser;

  const ChatEventInit({required this.chatId, required this.otherUser});
}

class ChatEventLoad implements ChatEvent {
  final int chatId;
  final User? otherUser;
  final bool withCache;

  const ChatEventLoad({
    required this.chatId,
    required this.otherUser,
    required this.withCache,
  }) : assert(
         otherUser != null || chatId != -1,
         "otherUser and chatId can't be empty at the same time",
       );
}

class ChatEventEmitMessages implements ChatEvent {
  final MessagesCollection data;

  const ChatEventEmitMessages({required this.data});
}

class ChatEventEmitError implements ChatEvent {
  final Object error;
  final StackTrace stackTrace;

  const ChatEventEmitError({required this.error, required this.stackTrace});
}

class ChatEventLoadMore implements ChatEvent {
  /// to load more if list was significantly scrolled on top
  final int? toMessageId;

  const ChatEventLoadMore({required this.toMessageId});
}

class ChatEventConnectingChanged implements ChatEvent {
  final bool isConnected;

  const ChatEventConnectingChanged(this.isConnected);
}

class ChatEventSendMessage implements ChatEvent {
  final String messageBody;

  const ChatEventSendMessage({required this.messageBody});
}

class ChatEventDeleteMessage implements ChatEvent {
  final int messageId;

  ChatEventDeleteMessage({required this.messageId});
}

class ChatEventReadAllMessages implements ChatEvent {
  const ChatEventReadAllMessages();
}

class ChatEventReadMessagesBeforeTime implements ChatEvent {
  final DateTime time;

  ChatEventReadMessagesBeforeTime({required this.time});
}

class ChatEventChangeUnreadCount implements ChatEvent {
  final int newCount;

  ChatEventChangeUnreadCount({required this.newCount});
}
