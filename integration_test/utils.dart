import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension TesterExtensions on WidgetTester {
  String? textByKey(Key key) => widget<Text>(find.byKey(key)).data;

  List<Key?> keysOfListByKey(Key listKey, Type childrenType) =>
      widgetList(
        find.descendant(
          of: find.byKey(const Key('chats_list_view')),
          matching: find.byType(childrenType),
        ),
      )
      .map((widget) => widget.key)
      .toList();
}

extension FinderExtensions on CommonFinders {
  Finder childrenWithText(Key parentKey, String text) =>
      find.descendant(of: find.byKey(parentKey), matching: find.text(text));

  Finder childrenWithKey(Key parentKey, Key key) =>
      find.descendant(of: find.byKey(parentKey), matching: find.byKey(key));

  Finder childrenWithIcon(Key parentKey, IconData icon) =>
      find.descendant(of: find.byKey(parentKey), matching: find.byIcon(icon));
}
