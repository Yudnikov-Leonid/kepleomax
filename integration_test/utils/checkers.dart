part of 'utils.dart';

class MessageChecker {
  final Finder finder;

  MessageChecker(this.finder);

  void check({
    bool? fromCurrentUser,
    bool? isRead,
    String? message,
    bool? isVisible,
    bool? fromCache,
  }) {
    if (isRead != null && fromCurrentUser == false) {
      throw Exception("you can't check the read status of anotherUser message");
    }

    if (fromCurrentUser != null) {
      expect(
        find.descendant(
          of: finder,
          matching: find.byKey(const Key('current_user_spacer')),
        ),
        fromCurrentUser ? findsOneWidget : findsNothing,
      );
    }
    if (isRead != null) {
      expect(
        find.descendant(
          of: finder,
          matching: find.byIcon(isRead ? Icons.check_box : Icons.check),
        ),
        findsOneWidget,
      );
    }
    if (message != null) {
      expect(
        find.descendant(
          of: finder,

          /// must be textContaining instead of text, cause messageWidget adds some
          /// spaces at the end for the timeWidget place correction
          matching: find.textContaining(message, findRichText: true),
        ),
        findsOneWidget,
      );
    }
    if (isVisible != null) {
      expect(finder, isVisible ? findsOneWidget : findsNothing);
    }
    if (fromCache != null) {
      final message =
          (finder.evaluate().elementAt(0).widget as MessageWidget).message;
      expect(message.fromCache, fromCache);
    }
  }
}

class ChatChecker {
  final Finder finder;

  ChatChecker(this.finder);

  void check({
    int? unreadCount, // 0 for check that counter not shown
    bool? unreadIcon,
    bool? readIcon,
    String? message,
    bool? msgFromCurrentUser,
    String? otherUserName,
  }) {
    if (unreadCount != null) {
      if (unreadCount == 0) {
        expect(
          find.descendant(
            of: finder,
            matching: find.byKey(const Key('chats_unread_text')),
          ),
          findsNothing,
        );
      } else {
        expect(
          find.descendant(of: finder, matching: find.text(unreadCount.toString())),
          findsOneWidget,
        );
      }
    }
    if (unreadIcon != null) {
      expect(
        find.descendant(of: finder, matching: find.byIcon(Icons.check)),
        unreadIcon ? findsOneWidget : findsNothing,
      );
    }
    if (readIcon != null) {
      expect(
        find.descendant(of: finder, matching: find.byIcon(Icons.check_box)),
        readIcon ? findsOneWidget : findsNothing,
      );
    }
    if (message != null) {
      expect(
        find.descendant(of: finder, matching: find.text(message)),
        findsOneWidget,
      );
    }
    if (msgFromCurrentUser != null) {
      expect(
        find.descendant(of: finder, matching: find.text('You: ')),
        msgFromCurrentUser ? findsOneWidget : findsNothing,
      );
    }
    if (otherUserName != null) {
      expect(
        find.descendant(of: finder, matching: find.text(otherUserName)),
        findsOneWidget,
      );
    }
  }
}
