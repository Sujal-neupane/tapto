import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:tapto/core/widgets/primary_button.dart';

void main() {
  testWidgets('PrimaryButton calls onTap when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: PrimaryButton(label: 'Tap me', onTap: () => tapped = true),
    ));
    await tester.tap(find.text('Tap me'));
    expect(tapped, true);
  });
}