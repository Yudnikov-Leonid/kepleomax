import 'package:flutter/material.dart';
import 'package:kepleomax/core/app_constants.dart';
import 'package:kepleomax/core/data/connection_repository.dart';

class ActivityScope extends StatefulWidget {
  const ActivityScope({
    required ConnectionRepository connectionRepository,
    required this.child,
    super.key,
  }) : _connectionRepository = connectionRepository;

  final ConnectionRepository _connectionRepository;
  final Widget child;

  static void addActivity(BuildContext context) =>
      context.findAncestorStateOfType<_ActivityScopeState>()!.addActivity();

  @override
  State<ActivityScope> createState() => _ActivityScopeState();
}

class _ActivityScopeState extends State<ActivityScope> {
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
