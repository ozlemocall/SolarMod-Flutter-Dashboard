import 'package:flutter_test/flutter_test.dart';
import 'package:solarmod/main.dart';  // Bu import doğru olmalı

void main() {
  testWidgets('App starts and shows title', (WidgetTester tester) async {
    await tester.pumpWidget(const SolarModApp());
    expect(find.text('SolarMod Kontrol'), findsOneWidget);
  });
}