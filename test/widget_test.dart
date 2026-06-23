import 'package:flutter_test/flutter_test.dart';

import 'package:byxex_match/app.dart';

void main() {
  testWidgets('Byxex Match app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const ByxexMatchApp());

    expect(find.byType(ByxexMatchApp), findsOneWidget);
  });
}
