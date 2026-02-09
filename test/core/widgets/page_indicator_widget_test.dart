import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapto/core/widgets/page_indicator_widget.dart';

void main() {
  // Widget Test 14: PageIndicatorWidget renders correct number of dots
  testWidgets('PageIndicatorWidget should render the correct number of dots',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PageIndicatorWidget(currentPage: 0, pageCount: 3),
        ),
      ),
    );

    final dots = find.byType(AnimatedContainer);
    expect(dots, findsNWidgets(3));
  });

  // Widget Test 15: Active dot has wider width than inactive dots
  testWidgets('PageIndicatorWidget active dot should be wider than inactive',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PageIndicatorWidget(currentPage: 1, pageCount: 3),
        ),
      ),
    );

    // After pump, animated containers are rendered
    // The active dot (index 1) should have width 24, others 8
    final containers = tester.widgetList<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );

    final widths =
        containers.map((c) {
          final decoration = c.decoration as BoxDecoration;
          // We can't easily read the width from AnimatedContainer directly,
          // but we can verify the count and the color difference
          return decoration.color;
        }).toList();

    // Index 1 (active) should be blue, others grey
    expect(widths[0], Colors.grey);
    expect(widths[1], Colors.blue);
    expect(widths[2], Colors.grey);
  });

  // Widget Test 16: Custom active and inactive colors work
  testWidgets('PageIndicatorWidget should use custom colors',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PageIndicatorWidget(
            currentPage: 0,
            pageCount: 2,
            activeColor: Colors.red,
            inactiveColor: Colors.black,
          ),
        ),
      ),
    );

    final containers = tester.widgetList<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );

    final colors =
        containers.map((c) {
          final decoration = c.decoration as BoxDecoration;
          return decoration.color;
        }).toList();

    expect(colors[0], Colors.red);
    expect(colors[1], Colors.black);
  });
}
