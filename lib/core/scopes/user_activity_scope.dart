import 'package:flutter/material.dart';
import 'package:kepleomax/core/app_constants.dart';
import 'package:kepleomax/core/data/connection_repository.dart';

class UserActivityScope extends StatefulWidget {
  const UserActivityScope({
    required ConnectionRepository connectionRepository,
    required this.child,
    super.key,
  }) : _connectionRepository = connectionRepository;

  final ConnectionRepository _connectionRepository;
  final Widget child;

  /// findAncestorStateOfType will be null if user is not logged in
  static void addActivity(BuildContext context) =>
      context.findAncestorStateOfType<_UserActivityScopeState>()?.addActivity();

  @override
  State<UserActivityScope> createState() => _UserActivityScopeState();
}

class _UserActivityScopeState extends State<UserActivityScope> {
  late DateTime _lastTimeActivityDetectedSent;

  @override
  void initState() {
    _lastTimeActivityDetectedSent = DateTime.now();
    super.initState();
  }

  void addActivity() {
    if (_lastTimeActivityDetectedSent.millisecondsSinceEpoch +
        AppConstants.sendActivityDelayInSeconds * 1000 <
        DateTime.now().millisecondsSinceEpoch) {
      print('activity sent');
      widget._connectionRepository.activityDetected();
      _lastTimeActivityDetectedSent = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        addActivity();
      },
      child: widget.child,
    );
  }
}
