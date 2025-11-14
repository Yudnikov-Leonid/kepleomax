import 'dart:async';

class Debouncer {
  final int milliseconds;

  Debouncer({required this.milliseconds});

  int _lastTimeRunCalled = 0;

  Future<void> run(Future Function() action) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    _lastTimeRunCalled = now;
    await Future.delayed(Duration(milliseconds: milliseconds));
    if (_lastTimeRunCalled == now) {
      await action.call();
    }
  }
}
