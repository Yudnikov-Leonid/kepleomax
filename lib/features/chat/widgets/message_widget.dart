part of '../chat_screen.dart';

class _MessageWidget extends StatelessWidget {
  const _MessageWidget({
    required this.message,
    required this.user,
    super.key,
  });

  final Message message;
  final User user;

  bool get _isCurrent => message.isCurrentUser;

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isCurrent)
            const Spacer()
          else ...[
            SizedBox(
              height: 35,
              width: 35,
              child: InkWell(
                onTap: () {
                  context.findAncestorStateOfType<AppNavigatorState>();

                  AppNavigator.withKeyOf(
                    context,
                    mainNavigatorKey,
                  )!.push(UserPage(userId: user.id));
                },
                child: UserImage(size: 35, url: user.profileImage),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Container(
            constraints: BoxConstraints(maxWidth: context.screenSize.width * 0.78),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: (_isCurrent ? KlmColors.currentUserBg : Colors.white).withGreen(
                message.fromCache ? 150 : 255,
              ),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: _isCurrent ? const Radius.circular(16) : Radius.zero,
                bottomRight: _isCurrent ? Radius.zero : const Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                /// text for time TODO fix, not working 100% correctly
                // Text(
                //   '${message.message}${_isCurrent ? '    ' : '  '}${ParseTime.unixTimeToTime(message.createdAt)}',
                //   style: context.textTheme.bodyMedium?.copyWith(
                //     fontSize: 15,
                //     color: Colors.red,
                //   ),
                // ),
                Linkify(
                  onOpen: (link) async {
                    await launchUrl(Uri.parse(link.url));
                  },
                  text: '${message.message}${_isCurrent ? '     ' : ' '}         ',
                  style: context.textTheme.bodyMedium?.copyWith(fontSize: 15),
                  options: const LinkifyOptions(removeWww: true),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Row(
                    children: [
                      Tooltip(
                        message: ParseTime.unixTimeToPreciseDate(message.createdAt),
                        triggerMode: TooltipTriggerMode.tap,
                        preferBelow: false,
                        showDuration: const Duration(seconds: 5),
                        child: Text(
                          //(DateTime.now().millisecondsSinceEpoch % 1000).toString(),
                          ParseTime.unixTimeToTime(message.createdAt),
                          textScaler: const TextScaler.linear(1),
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
          if (!_isCurrent) const Spacer(),
        ],
      ),
    );
  }
}
