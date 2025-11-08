import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kepleomax/core/navigation/pages.dart';

typedef AppPages = List<AppPage>;

const mainNavigatorKey = 'MainNavigator';

class AppNavigator extends StatefulWidget {
  const AppNavigator({required this.initialState, required this.navigatorKey, super.key});

  final AppPages initialState;
  final String navigatorKey;

  static AppNavigatorState? firstOf(BuildContext context) =>
      context.findAncestorStateOfType<AppNavigatorState>();

  static AppNavigatorState? withKeyOf(BuildContext context, String key) {
    AppNavigatorState? state = context
        .findAncestorStateOfType<AppNavigatorState>();

    while (true) {
      if (state == null) return null;
      if (state.navigatorKey == key) return state;

      state = state.context.findAncestorStateOfType<AppNavigatorState>();
    }
  }

  static void change(BuildContext context, AppPages Function(AppPages pages) fn) =>
      firstOf(context)?.change(fn);

  static void push(BuildContext context, AppPage page) => firstOf(context)?.push(page);

  static void pop(BuildContext context) => firstOf(context)?.pop();

  @override
  State<AppNavigator> createState() => AppNavigatorState();
}

class AppNavigatorState extends State<AppNavigator> with WidgetsBindingObserver {
  AppPages get state => _state;
  late AppPages _state;
  bool _canPop = true;

  @override
  void initState() {
    _state = widget.initialState;
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  void setCanPop(bool value) {
    _canPop = value;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void change(AppPages Function(AppPages pages) fn) {
    if (!mounted) return;

    final next = fn(_state.toList());

    if (next.isEmpty || listEquals(_state, next)) return;
    _state = next;

    setState(() {});
  }

  void push(AppPage page) {
    change((state) => [...state, page]);
  }

  void pop() => change((state) {
    if (state.length > 1) state.removeLast();
    return state;
  });

  String get navigatorKey => widget.navigatorKey;

  @override
  Future<bool> didPopRoute() async {
    if (!_canPop) return true;
    if (_state.length <= 1) return false;
    _onDidRemovePage(_state.last);
    return true;
  }

  void _onDidRemovePage(Page<Object?> page) {
    change(
      (pages) => pages
        ..toList()
        ..removeWhere((e) => e.key == page.key),
    );
  }

  @override
  Widget build(BuildContext context) =>
      Navigator(pages: _state, onDidRemovePage: _onDidRemovePage);
}
