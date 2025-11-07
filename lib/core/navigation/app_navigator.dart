import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kepleomax/core/navigation/pages.dart';

typedef AppPages = List<AppPage>;

class AppNavigator extends StatefulWidget {
  const AppNavigator({required this.initialState, super.key});

  final AppPages initialState;

  static AppNavigatorState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<AppNavigatorState>();

  static void change(
    BuildContext context,
    AppPages Function(AppPages pages) fn,
  ) => maybeOf(context)?.change(fn);

  static void push(BuildContext context, AppPage page) =>
      change(context, (state) => [...state, page]);

  static void pop(BuildContext context) => change(context, (state) {
    if (state.length > 1) state.removeLast();
    return state;
  });

  static void setCanPop(BuildContext context, bool value) =>
      maybeOf(context)?.setCanPop(value);

  @override
  State<AppNavigator> createState() => AppNavigatorState();
}

class AppNavigatorState extends State<AppNavigator>
    with WidgetsBindingObserver {
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
