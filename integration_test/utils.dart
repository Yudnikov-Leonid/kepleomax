import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension TesterExtensions on WidgetTester {
  String? textByKey(Key key) => widget<Text>(find.byKey(key)).data;
}

extension FinderExtensions on CommonFinders {
  Finder childrenWithText(Key parentKey, String text) =>
      find.descendant(of: find.byKey(parentKey), matching: find.text(text));

  Finder childrenWithIcon(Key parentKey, IconData icon) =>
      find.descendant(of: find.byKey(parentKey), matching: find.byIcon(icon));
}
