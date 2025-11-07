import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/main.dart';

Future<Dependencies> initializeDependencies() async {
  final dp = Dependencies();

  for (final step in _steps) {
    try {
      step.call(dp);
    } catch (e, st) {
      logger.e(
        'Error while initializing step ${step.name}: $e',
        stackTrace: st,
      );
      rethrow;
    }
  }

  return dp;
}

List<_InitializationStep> _steps = [
  _InitializationStep(name: 'Repositories', call: (dependencies) {}),
];

class _InitializationStep {
  final String name;
  final Function(Dependencies) call;

  _InitializationStep({required this.name, required this.call});
}
