part of '../chat_screen.dart';

class _MessageWidget extends StatelessWidget {
  const _MessageWidget({
    required this.message,
    required this.user,
    required this.onDelete,
    super.key,
  });

  final Message message;
  final User user;
  final VoidCallback onDelete;

  bool get _isCurrent => message.isCurrentUser;

  @override
  Widget build(BuildContext context) {
    if (message.id == Message.unreadMessagesId) {
      return const _UnreadMessagesWidget();
    }

    if (message.id == Message.dateId) {
      return _ChatDateWidget(date: message.createdAt);
    }

    final globalKey = GlobalKey();
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
          InkWell(
            onTap: () {
              final renderBox =
                  globalKey.currentContext?.findRenderObject() as RenderBox?;
              if (renderBox == null) return;
              final pos = renderBox.localToGlobal(Offset.zero);

              showMenu(
                context: context,
                color: Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                position: RelativeRect.fromRect(
                  Rect.fromLTRB(
                    pos.dx,
                    pos.dy + renderBox.size.height,
                    message.isCurrentUser ? 1000 : 0,
                    0,
                  ),
                  Offset.zero & renderBox.size,
                ),
                items: _items(),
              );
            },
            child: Container(
              key: globalKey,
              constraints: BoxConstraints(maxWidth: context.screenSize.width * 0.78),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: (_isCurrent ? KlmColors.currentUserBg : Colors.white)
                    .withGreen(message.fromCache ? 150 : 255),
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
                          message: ParseTime.toPreciseDate(message.createdAt),
                          triggerMode: TooltipTriggerMode.longPress,
                          preferBelow: false,
                          showDuration: const Duration(seconds: 5),
                          child: Text(
                            //(DateTime.now().millisecondsSinceEpoch % 1000).toString(),
                            ParseTime.toTime(message.createdAt),
                            textScaler: const TextScaler.linear(1),
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: _isCurrent
                                  ? KlmColors.readMessage
                                  : Colors.grey,
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
          ),
          if (!_isCurrent) const Spacer(),
        ],
      ),
    );
  }

  List<PopupMenuEntry> _items() {
    return [
      if (!message.fromCache) _popupItem('Reply', Icons.reply, () {}),
      _popupItem('Copy', Icons.copy, () {
        Clipboard.setData(ClipboardData(text: message.message));
      }),
      if (message.isCurrentUser && !message.fromCache) ...[
        _popupItem('Edit', Icons.edit, () {}),
        _popupItem('Delete', Icons.delete, onDelete, color: Colors.red),
      ],
    ];
  }

  PopupMenuItem _popupItem(
    String text,
    IconData iconData,
    VoidCallback onTap, {
    Color? color,
  }) => PopupMenuItem(
    onTap: onTap,
    child: Row(
      children: [
        Text(
          text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: color),
        ),
        const Spacer(),
        Icon(iconData, color: color),
      ],
    ),
  );
}

class _UnreadMessagesWidget extends StatelessWidget {
  const _UnreadMessagesWidget();

  @override
  Widget build(BuildContext context) {
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
}

class _ChatDateWidget extends StatelessWidget {
  const _ChatDateWidget({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: KlmColors.primaryColor.shade700.withAlpha(65),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          ParseTime.toDate(date),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
