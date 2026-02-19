import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/app_constants.dart';
import 'package:kepleomax/core/data/chats_repository.dart';
import 'package:kepleomax/core/data/connection_repository.dart';
import 'package:kepleomax/core/data/messenger/messenger_repository.dart';
import 'package:kepleomax/core/data/models/messages_collection.dart';
import 'package:kepleomax/core/flavor.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/network/websockets/models/online_status_update.dart';
import 'package:kepleomax/core/network/websockets/models/typing_activity_update.dart';
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
  late StreamSubscription _onlineUpdatesSub;
  late StreamSubscription _typingUpdatesSub;

  ChatBloc({
    required MessengerRepository messengerRepository,
    required ChatsRepository chatsRepository,
    required ConnectionRepository connectionRepository,
    required int chatId,
  }) : _messengerRepository = messengerRepository,
       _chatsRepository = chatsRepository,
       _connectionRepository = connectionRepository,
       super(ChatStateBase.initial()) {
    _messagesUpdatesSub = _messengerRepository.messagesUpdatesStream.listen(
      (data) {
        add(_ChatEventEmitMessages(data: data));
      },
      onError: (e, st) {
        add(_ChatEventEmitError(error: e, stackTrace: st));
      },
    );
    _chatUpdatesSub = _messengerRepository.chatsUpdatesStream.listen((newList) {
      final currentChat = newList.chats.where((e) => e.id == chatId).firstOrNull;
      if (currentChat != null) {
        add(_ChatEventChangeUnreadCount(newCount: currentChat.unreadCount));
      }
    });
    _connectionStateSub = _connectionRepository.connectionStateStream.listen(
      (isConnected) => add(_ChatEventConnectingChanged(isConnected)),
    );
    _onlineUpdatesSub = _connectionRepository.onlineUpdatesStream.listen((update) {
      add(_ChatEventOnlineStatusUpdate(update));
    });
    _typingUpdatesSub = _connectionRepository.typingUpdatesStream.listen((update) {
      if (_data.chatId != update.chatId) return;
      add(_ChatEventTypingUpdate(update));
    });

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
    on<ChatEventEditText>(_onEditText);

    /// local events
    on<_ChatEventTypingUpdate>(_onTypingUpdate, transformer: restartable());
    on<_ChatEventEmitOtherUser>(_onEmitOtherUser);
    on<_ChatEventOnlineStatusUpdate>(_onOnlineStatusUpdate);
    on<_ChatEventEmitError>(_onEmitError);
    on<_ChatEventEmitMessages>(_onEmitMessages);
    on<_ChatEventConnectingChanged>(_onConnectionChanged);
    on<_ChatEventChangeUnreadCount>(_onChangeUnreadCount);
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
          print('chatFromApi: $chat');
          chatId = chat?.id ?? -1;
        }

        if (chatId == -1) {
          /// it's a new chat with new user
          _data = _data.copyWith(chatId: -1, isLoading: false, messages: []);
          emit(ChatStateBase(data: _data));
          _messengerRepository.listenToMessagesWithOtherUserId(
            otherUserId: event.otherUser!.id,
          );
          _connectionRepository.listenOnlineStatusUpdates(
            usersIds: [_data.otherUser!.id],
          );
          return;
        } else {
          /// it's existing chat with otherUser, but was opened not from chat page
          _data = _data.copyWith(chatId: chatId);
        }
      }
      if (event.otherUser == null) {
        /// chat was opened from notification

        final chat = await _chatsRepository.getChatWithId(chatId);
        _data = _data.copyWith(otherUser: chat!.otherUser);
      } else {
        /// update user anyway, cause isOnline can be different
        Future(() async {
          final otherUser = (await _chatsRepository.getChatWithId(
            chatId,
          ))!.otherUser;
          if (otherUser != _data.otherUser) {
            add(_ChatEventEmitOtherUser(otherUser));
          }
        });
      }
      final chat = _messengerRepository.currentChatsCollection.chats
          .where((c) => c.id == chatId)
          .firstOrNull;
      if (chat?.isTypingRightNow == true) {
        add(
          _ChatEventTypingUpdate(
            TypingActivityUpdate(chatId: chatId, isTyping: true),
          ),
        );
      }
      _data = _data.copyWith(unreadCount: chat?.unreadCount ?? 0);
      emit(ChatStateBase(data: _data));

      _connectionRepository.listenOnlineStatusUpdates(
        usersIds: [_data.otherUser!.id],
      );
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
      messageBody: event.value,
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

  int _lastTimeActivityWasSent = 0;

  void _onEditText(ChatEventEditText event, Emitter<ChatState> emit) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_lastTimeActivityWasSent + 1000 > now) {
      return;
    }
    _lastTimeActivityWasSent = now;

    if (event.value.isNotEmpty) {
      _connectionRepository.typingActivityDetected(chatId: _data.chatId);
    }
  }

  /// private events
  void _onConnectionChanged(
    _ChatEventConnectingChanged event,
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
    _ChatEventChangeUnreadCount event,
    Emitter<ChatState> emit,
  ) {
    _data = _data.copyWith(unreadCount: event.newCount);
    emit(ChatStateBase(data: _data));
  }

  void _onEmitMessages(_ChatEventEmitMessages event, Emitter<ChatState> emit) {
    final messages = event.data.messages.toList(growable: false);
    final newMessages = <Message>[];

    /// save unreadMessages widget position
    final unreadMessagesIsRequired =
        messages.isNotEmpty && !messages[0].isCurrentUser && !messages[0].isRead;
    final handleUnreadMessages =
        messages.isNotEmpty &&
        !_data.unreadMessagesValue.isLocked &&
        (event.data.maintainLoading == false || messages.length > 1);

    /// event.data.maintainLoading == false || messages.length > 1 means:
    /// either messages are from api, not from cache, OR messages from cache, but
    /// if there is only 1 message -> that means the message from chat.lastMessage
    /// and chat is not loaded
    if (unreadMessagesIsRequired && handleUnreadMessages) {
      _data = _data.copyWith(
        unreadMessagesValue: UnreadMessagesValue(
          isLocked: !event.data.maintainLoading,
          firstReadMessageCreatedAt:
              messages.firstWhereOrNull((m) => m.isRead)?.createdAt ??
              DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );
    } else if (handleUnreadMessages) {
      _data = _data.copyWith(
        unreadMessagesValue: UnreadMessagesValue(
          isLocked: !event.data.maintainLoading,
          firstReadMessageCreatedAt: null,
        ),
      );
    }
    // here after first emit not from cache, unreadMessages will be established, and will never change

    for (int i = 0; i < messages.length; i++) {
      newMessages.add(messages[i]);

      final createdAt1 = messages[i].createdAt;
      final createdAt2 = messages.elementAtOrNull(i + 1)?.createdAt;

      /// add unreadMessages widget
      if (_data.unreadMessagesValue.firstReadMessageCreatedAt != null) {
        final firstReadMessageCreatedAt = _data
            .unreadMessagesValue
            .firstReadMessageCreatedAt!
            .millisecondsSinceEpoch;
        if (createdAt1.millisecondsSinceEpoch > firstReadMessageCreatedAt &&
            (createdAt2?.millisecondsSinceEpoch ?? 0) <= firstReadMessageCreatedAt) {
          newMessages.add(Message.unreadMessages());
        }
      }

      /// add date widgets
      if (createdAt2 == null ||
          createdAt1.day > createdAt2.day ||
          createdAt1.month > createdAt2.month ||
          createdAt1.year > createdAt2.year) {
        newMessages.add(Message.date(createdAt1));
      }
    }

    /// emit
    _data = _data.copyWith(
      // chatId can be changed if initially it was -1
      chatId: event.data.chatId,
      messages: newMessages,
      isLoading: event.data.maintainLoading,
    );
    if (event.data.allMessagesLoaded != null) {
      _data = _data.copyWith(isAllMessagesLoaded: event.data.allMessagesLoaded!);
    }
    emit(ChatStateBase(data: _data));
  }

  void _onOnlineStatusUpdate(
    _ChatEventOnlineStatusUpdate event,
    Emitter<ChatState> emit,
  ) {
    final update = event.update;
    if (_data.otherUser?.id == update.userId) {
      _data = _data.copyWith(
        otherUser: _data.otherUser?.copyWith(
          isOnline: update.isOnline,
          lastActivityTime: update.lastActivityTime,
        ),
      );
      emit(ChatStateBase(data: _data));
    }
  }

  void _onEmitError(_ChatEventEmitError event, Emitter<ChatState> emit) {
    final e = event.error;
    final st = event.stackTrace;
    logger.e(e, stackTrace: st);
    emit(ChatStateMessage(message: e.userErrorMessage, isError: true));
    emit(ChatStateBase(data: _data));
  }

  void _onEmitOtherUser(_ChatEventEmitOtherUser event, Emitter<ChatState> emit) {
    _data = _data.copyWith(otherUser: event.otherUser);
    emit(ChatStateBase(data: _data));
  }

  void _onTypingUpdate(_ChatEventTypingUpdate event, Emitter<ChatState> emit) async {
    _data = _data.copyWith(isTyping: event.update.isTyping);
    emit(ChatStateBase(data: _data));
    if (!event.update.isTyping) return;

    await Future.delayed(
      const Duration(seconds: AppConstants.showTypingAfterActivityForSeconds),
    );
    _data = _data.copyWith(isTyping: false);
    emit(ChatStateBase(data: _data));
  }

  @override
  Future<void> close() {
    _messagesUpdatesSub.cancel();
    _connectionStateSub.cancel();
    _chatUpdatesSub.cancel();
    _onlineUpdatesSub.cancel();
    _typingUpdatesSub.cancel();
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

class ChatEventLoadMore implements ChatEvent {
  /// to load more if list was significantly scrolled on top
  final int? toMessageId;

  const ChatEventLoadMore({required this.toMessageId});
}

class ChatEventSendMessage implements ChatEvent {
  final String value;

  const ChatEventSendMessage({required this.value});
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

class ChatEventEditText implements ChatEvent {
  final String value;

  ChatEventEditText({required this.value});
}

class _ChatEventConnectingChanged implements ChatEvent {
  final bool isConnected;

  const _ChatEventConnectingChanged(this.isConnected);
}

class _ChatEventEmitOtherUser implements ChatEvent {
  final User otherUser;

  _ChatEventEmitOtherUser(this.otherUser);
}

class _ChatEventOnlineStatusUpdate implements ChatEvent {
  final OnlineStatusUpdate update;

  _ChatEventOnlineStatusUpdate(this.update);
}

class _ChatEventTypingUpdate implements ChatEvent {
  final TypingActivityUpdate update;

  _ChatEventTypingUpdate(this.update);
}

class _ChatEventChangeUnreadCount implements ChatEvent {
  final int newCount;

  _ChatEventChangeUnreadCount({required this.newCount});
}

class _ChatEventEmitMessages implements ChatEvent {
  final MessagesCollection data;

  const _ChatEventEmitMessages({required this.data});
}

class _ChatEventEmitError implements ChatEvent {
  final Object error;
  final StackTrace stackTrace;

  const _ChatEventEmitError({required this.error, required this.stackTrace});
}
