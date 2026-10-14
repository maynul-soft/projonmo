import 'package:flutter_test/flutter_test.dart';
import 'package:delmonte_mlm/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DelMonteApp());
    expect(find.byType(DelMonteApp), findsOneWidget);
  });
}
