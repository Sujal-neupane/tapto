import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapto/core/utils/responsive_utils.dart';

void main() {
  testWidgets('ResponsiveUtils correctly identifies device type', (tester) async {
    Widget buildWithWidth(double width) {
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(width, 800)),
          child: Builder(
            builder: (context) {
              // Just return a container, logic is in test
              return Container();
            },
          ),
        ),
      );
    }

    // Mobile
    await tester.pumpWidget(buildWithWidth(400));
    expect(ResponsiveUtils.isMobile(tester.element(find.byType(Container))), true);
    expect(ResponsiveUtils.isTablet(tester.element(find.byType(Container))), false);
    expect(ResponsiveUtils.isDesktop(tester.element(find.byType(Container))), false);

    // Tablet
    await tester.pumpWidget(buildWithWidth(800));
    expect(ResponsiveUtils.isMobile(tester.element(find.byType(Container))), false);
    expect(ResponsiveUtils.isTablet(tester.element(find.byType(Container))), true);
    expect(ResponsiveUtils.isDesktop(tester.element(find.byType(Container))), false);

    // Desktop
    await tester.pumpWidget(buildWithWidth(1300));
    expect(ResponsiveUtils.isMobile(tester.element(find.byType(Container))), false);
    expect(ResponsiveUtils.isTablet(tester.element(find.byType(Container))), false);
    expect(ResponsiveUtils.isDesktop(tester.element(find.byType(Container))), true);
  });
}