import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budget_app/main.dart';

void main() {
  testWidgets('BudgetApp loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BudgetApp());

    // Verify that the dashboard is loaded.
    expect(find.text('Budget Dashboard'), findsOneWidget);
  });
}
