import 'package:flutter/services.dart';

class KlmMethodChannel {
  final _platform = const MethodChannel('base.channel');

  Future<void> moveTaskToBack() async {
    await _platform.invokeMethod('moveTaskToBack');
  }
}
