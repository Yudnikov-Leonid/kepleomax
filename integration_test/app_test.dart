import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kepleomax/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('chats', () {
    testWidgets('empty_chats', (tester) async {
      app.main();
      await tester.pumpAndSettle();
    });
  });
}
