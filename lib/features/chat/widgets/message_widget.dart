part of '../chat_screen.dart';

class _MessageWidget extends StatelessWidget {
  const _MessageWidget({required this.message, required this.user, super.key});

  final Message message;
  final User user;

  bool get _isCurrent => message.user.isCurrent;

  @override
  Widget build(BuildContext context) {
    if (message.id == -2) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        width: double.infinity,
        height: 20,
        color: Colors.grey.shade100,
        child: Center(
          child: Text(
            'Unread Messages',
            style: context.textTheme.bodyMedium?.copyWith(
              color: KlmColors.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isCurrent)
            const Expanded(child: SizedBox())
          else ...[
            InkWell(
              onTap: () {
                context.findAncestorStateOfType<AppNavigatorState>();

                AppNavigator.withKeyOf(
                  context,
                  mainNavigatorKey,
                )!.push(UserPage(userId: user.id));
              },
              child: UserImage(size: 35, url: user.profileImage),
            ),
            const SizedBox(width: 10),
          ],
          Container(
            constraints: BoxConstraints(maxWidth: context.screenSize.width * 0.78),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _isCurrent
                  ? const Color.fromARGB(255, 213, 255, 255)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Text(
                  message.message,
                  style: context.textTheme.bodyMedium?.copyWith(fontSize: 15),
                ),
                Text(
                  '${message.message}${_isCurrent ? '    ' : '  '}${ParseTime.unixTimeToTime(message.createdAt)}',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    color: Colors.transparent,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Row(
                    children: [
                      Tooltip(
                        message:
                        ParseTime.unixTimeToPreciseDate(message.createdAt),
                        triggerMode: TooltipTriggerMode.tap,
                        preferBelow: false,
                        showDuration: const Duration(seconds: 5),
                        child: Text(
                          ParseTime.unixTimeToTime(message.createdAt),
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: _isCurrent ? KlmColors.readMessage : Colors.grey,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      if (_isCurrent)
                        Icon(
                          message.isRead ? Icons.check_box : Icons.check,
                          size: 14,
                          color: KlmColors.readMessage,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!_isCurrent) const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}