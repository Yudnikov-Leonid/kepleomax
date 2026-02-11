part of '../chats_screen.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({required this.chat, this.isLoading = false, super.key});

  final Chat chat;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: 70,
      child: InkWell(
        onTap: isLoading
            ? null
            : () {
          AppNavigator.withKeyOf(
            context,
            mainNavigatorKey,
          )!.push(ChatPage(chatId: chat.id, otherUser: chat.otherUser));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 60,
                width: 60,
                child: UserImage(url: chat.otherUser.profileImage),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.otherUser.username,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    if (chat.lastMessage != null) ...[
                      const SizedBox(height: 4),
                      FittedBox(
                        child: Row(
                          children: [
                            if (chat.lastMessage!.isCurrentUser)
                              Text(
                                'You: ',
                                style: context.textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: context.screenSize.width * 0.3,
                              ),
                              child: Text(
                                chat.lastMessage!.message,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.bodyLarge?.copyWith(
                                  fontSize: 15,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              ' • ${ParseTime.toPassTimeSlim(chat.lastMessage!.createdAt)}',
                              style: context.textTheme.bodyLarge?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (chat.lastMessage?.isCurrentUser ?? false)
                Icon(chat.lastMessage!.isRead ? Icons.check_box : Icons.check)
              else if (chat.lastMessage != null && chat.unreadCount > 0)
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: KlmColors.primaryColor,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    chat.unreadCount.toString(),
                    key: const Key('chat_unread_count_text'),
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}