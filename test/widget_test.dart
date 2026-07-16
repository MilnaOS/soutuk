import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soutuk/main.dart';

void main() {
  testWidgets('Soutuk smoke test - App renders HomeScreen', (WidgetTester tester) async {
    // Build our app under ProviderScope and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: SoutukApp()));

    // Verify that the title "Soutuk" is displayed.
    expect(find.text('Soutuk'), findsOneWidget);
  });
}
