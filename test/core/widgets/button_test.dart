import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:tapto/core/widgets/button.dart';

void main() {
  testWidgets('TaptoButton displays label and responds to tap', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaptoButton(
            label: 'Tapto',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    // Check label
    expect(find.text('Tapto'), findsOneWidget);

    // Tap and check callback
    await tester.tap(find.text('Tapto'));
    expect(tapped, true);
  });
}