import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kepleomax/features/chats/chats_screen.dart';

extension TesterExtension on WidgetTester {
  String? textByKey(Key key) => widget<Text>(find.byKey(key)).data;

  List<Key?> keysOfListByKey(Key listKey, Type childrenType) => widgetList(
    find.descendant(
      of: find.byKey(const Key('chats_list_view')),
      matching: find.byType(childrenType),
    ),
  ).map((widget) => widget.key).toList();

  Finder getChat(int id) => find.byKey(Key('chat-$id'));

  void checkAppBarText(String expected) {
    expect(textByKey(const Key('app_bar_text')), equals(expected));
  }

  void checkFindPeopleButton({required bool isShown}) {
    expect(
      find.byKey(const Key('find_people_button')),
      isShown ? findsOneWidget : findsNothing,
    );
  }

  void checkTotalUnreadCount(int expected) {
    expect(textByKey(const Key('chats_unread_text')), equals(expected.toString()));
  }

  void checkChatsOrder(List<int> ids) {
    expect(
      keysOfListByKey(const Key('chats_list_view'), ChatWidget),
      equals(ids.map((id) => Key('chat-$id'))),
    );
  }
}

extension FinderExtension on CommonFinders {
  Finder childrenWithText(Key parentKey, String text) =>
      find.descendant(of: find.byKey(parentKey), matching: find.text(text));

  Finder childrenWithKey(Key parentKey, Key key) =>
      find.descendant(of: find.byKey(parentKey), matching: find.byKey(key));

  Finder childrenWithIcon(Key parentKey, IconData icon) =>
      find.descendant(of: find.byKey(parentKey), matching: find.byIcon(icon));
}

extension FinderChatExtension on Finder {
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
            of: this,
            matching: find.byKey(const Key('chats_unread_text')),
          ),
          findsNothing,
        );
      } else {
        expect(
          find.descendant(of: this, matching: find.text(unreadCount.toString())),
          findsOneWidget,
        );
      }
    }
    if (unreadIcon != null) {
      expect(
        find.descendant(of: this, matching: find.byIcon(Icons.check)),
        unreadIcon ? findsOneWidget : findsNothing,
      );
    }
    if (readIcon != null) {
      expect(
        find.descendant(of: this, matching: find.byIcon(Icons.check_box)),
        readIcon ? findsOneWidget : findsNothing,
      );
    }
    if (message != null) {
      expect(
        find.descendant(of: this, matching: find.text(message)),
        findsOneWidget,
      );
    }
    if (msgFromCurrentUser != null) {
      expect(
        find.descendant(of: this, matching: find.text('You: ')),
        msgFromCurrentUser ? findsOneWidget : findsNothing,
      );
    }
    if (otherUserName != null) {
      expect(
        find.descendant(of: this, matching: find.text(otherUserName)),
        findsOneWidget,
      );
    }
  }
}
