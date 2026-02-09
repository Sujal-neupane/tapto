import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapto/core/widgets/primary_button.dart';

void main() {
  // Widget Test 1: PrimaryButton renders label
  testWidgets('PrimaryButton should display the label text',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(label: 'Sign In', onTap: () {}),
        ),
      ),
    );

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  // Widget Test 2: PrimaryButton triggers onTap
  testWidgets('PrimaryButton should trigger onTap callback when pressed',
      (WidgetTester tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(label: 'Submit', onTap: () => tapped = true),
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(tapped, true);
  });

  // Widget Test 3: PrimaryButton has full width
  testWidgets('PrimaryButton should take full width',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(label: 'Go', onTap: () {}),
        ),
      ),
    );

    final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
    expect(sizedBox.width, double.infinity);
  });
}
