import 'package:flutter/material.dart';

class Dependencies {
  Widget inject({required Widget child}) =>
      InheritedDependencies(dependencies: this, child: child);

  static Dependencies of(BuildContext context) => context
      .getInheritedWidgetOfExactType<InheritedDependencies>()!
      .dependencies;
}

class InheritedDependencies extends InheritedWidget {
  const InheritedDependencies({
    required this.dependencies,
    required super.child,
    super.key,
  });

  final Dependencies dependencies;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
