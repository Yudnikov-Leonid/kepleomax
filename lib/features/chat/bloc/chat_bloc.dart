import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/data/chats_repository.dart';
import 'package:kepleomax/core/data/connection_repository.dart';
import 'package:kepleomax/core/data/messenger_repository.dart';
import 'package:kepleomax/core/data/models/messages_collection.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/presentation/user_error_message.dart';
import 'package:kepleomax/main.dart';
import 'package:rxdart/rxdart.dart';

import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final IMessengerRepository _messengerRepository;
  final IChatsRepository _chatsRepository;
  final IConnectionRepository _connectionRepository;
  late ChatData _data = ChatData.initial();
  late StreamSubscription _messagesUpdatesSub;
  late StreamSubscription _connectionStateSub;
  late StreamSubscription _chatUpdatesSub;

  ChatBloc({
    required IMessengerRepository messengerRepository,
    required IChatsRepository chatsRepository,
    required IConnectionRepository connectionRepository,
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
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - 1000 < _lastTimeLoadWasCalled) {
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

    int chatId = event.chatId;
    try {
      /// either chatId == -1 and we have otherUser, or otherUser == null and we have chatId
      if (event.chatId == -1) {
        final chat = await _chatsRepository.getChatWithUser(event.otherUser!.id);
        if (chat == null) {
          /// it's new chat with new user
          _data = _data.copyWith(chatId: -1, isLoading: false, messages: []);
          emit(ChatStateBase(data: _data));
          return;
        } else {
          /// it's existing chat with otherUser, but was opened not from chat page
          chatId = chat.id;
          _data = _data.copyWith(chatId: chat.id);
        }
      } else if (event.otherUser == null) {
        /// chat was opened from notification
        final chat = await _chatsRepository.getChatWithId(event.chatId);
        _data = _data.copyWith(otherUser: chat!.otherUser);
      }

      await _messengerRepository.loadMessages(
        chatId: chatId,
        withCache: event.withCache,
      );
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(ChatStateError(message: e.userErrorMessage));
      return;
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

  // void _onLoadCache(ChatEventLoadCache event, Emitter<ChatState> emit) async {
  //   try {
  //     print(
  //       'ChatBloc onLoadCache: chatId: ${event.chatId}, otherUser: ${event.otherUser}',
  //     );
  //
  //     /// set chatId
  //     final int? chatId;
  //     if (event.chatId == -1) {
  //       chatId = (await _chatsRepository.getChatWithUserFromCache(
  //         event.otherUser!.id,
  //       ))?.id;
  //     } else {
  //       chatId = event.chatId;
  //     }
  //
  //     /// get cache
  //     final List<Message> cache = chatId == null || chatId == -1
  //         ? []
  //         : await _messagesRepository.getMessagesFromCache(chatId: chatId);
  //
  //     /// set otherUser
  //     final User? otherUser;
  //     if (event.otherUser == null) {
  //       final chat = await _chatsRepository.getChatWithIdFromCache(chatId!);
  //       otherUser = chat?.otherUser;
  //     } else {
  //       otherUser = event.otherUser;
  //     }
  //
  //     print('ChatBloc loadCache, set chatId: $chatId, otherUser: $otherUser');
  //     _data = _data.copyWith(
  //       chatId: chatId ?? -1,
  //       messages: _withUnreadMessages(cache),
  //       otherUser: otherUser,
  //     );
  //   } catch (e, st) {
  //     logger.e(e, stackTrace: st);
  //     emit(const ChatStateMessage(message: 'Failed to load cache', isError: true));
  //   } finally {
  //     emit(ChatStateBase(data: _data));
  //   }
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

  // void _onReadMessagesUpdate(
  //   ChatEventReadMessagesUpdate event,
  //   Emitter<ChatState> emit,
  // ) {
  //   if (_data.chatId != event.updates.chatId) return;
  //
  //   final updates = event.updates.messagesIds;
  //   final newMessages = <Message>[];
  //   for (final message in _data.messages) {
  //     /// TODO optimize
  //     if (updates.contains(message.id)) {
  //       newMessages.add(message.copyWith(isRead: true));
  //       NotificationService.instance.closeNotification(message.id);
  //     } else {
  //       newMessages.add(message);
  //     }
  //   }
  //   _data = _data.copyWith(messages: newMessages);
  //   emit(ChatStateBase(data: _data));
  // }

  void _onSendMessage(ChatEventSendMessage event, Emitter<ChatState> emit) {
    _connectionRepository.sendMessage(
      message: event.message,
      recipientId: event.otherUserId,
    );
  }

  void _onLoadMore(ChatEventLoadMore event, Emitter<ChatState> emit) async {
    if (_data.isAllMessagesLoaded || _data.isLoading) return;

    try {
      await _messengerRepository.loadMoreMessages(
        chatId: _data.chatId,
        toMessageId: event.cachedMessageId,
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
    print('ChatBloc connectionChanged: ${event.isConnected}');
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
    _data = _data.copyWith(
      messages: event.data.messages.toList(growable: false),
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
  });
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
  final int? cachedMessageId;

  const ChatEventLoadMore({required this.cachedMessageId});
}

class ChatEventConnectingChanged implements ChatEvent {
  final bool isConnected;

  const ChatEventConnectingChanged(this.isConnected);
}

class ChatEventSendMessage implements ChatEvent {
  final String message;
  final int otherUserId;

  const ChatEventSendMessage({required this.message, required this.otherUserId});
}

class ChatEventReadAllMessages implements ChatEvent {
  const ChatEventReadAllMessages();
}

class ChatEventReadMessagesBeforeTime implements ChatEvent {
  final int time;

  ChatEventReadMessagesBeforeTime({required this.time});
}

class ChatEventChangeUnreadCount implements ChatEvent {
  final int newCount;

  ChatEventChangeUnreadCount({required this.newCount});
}
