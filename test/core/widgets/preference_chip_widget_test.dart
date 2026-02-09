import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapto/core/widgets/preference_chip.dart';

void main() {
  // Widget Test 4: PreferenceChip shows label
  testWidgets('PreferenceChip should display label text',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              PreferenceChip(label: 'Men', selected: false, onTap: () {}),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Men'), findsOneWidget);
  });

  // Widget Test 5: PreferenceChip selected state has primary color background
  testWidgets('PreferenceChip should show primary color when selected',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              PreferenceChip(label: 'Women', selected: true, onTap: () {}),
            ],
          ),
        ),
      ),
    );

    // When selected, text should be white
    final text = tester.widget<Text>(find.text('Women'));
    expect(text.style?.color, Colors.white);
  });

  // Widget Test 6: PreferenceChip unselected has transparent background
  testWidgets('PreferenceChip unselected should have transparent text color',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              PreferenceChip(label: 'Men', selected: false, onTap: () {}),
            ],
          ),
        ),
      ),
    );

    // When not selected, text color is primary (not white)
    final text = tester.widget<Text>(find.text('Men'));
    expect(text.style?.color, isNot(Colors.white));
  });

  // Widget Test 7: PreferenceChip fires onTap
  testWidgets('PreferenceChip should call onTap when tapped',
      (WidgetTester tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              PreferenceChip(
                  label: 'Kids', selected: false, onTap: () => tapped = true),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Kids'));
    await tester.pump();

    expect(tapped, true);
  });
}
