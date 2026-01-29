import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:tapto/core/widgets/onboarding_page_widget.dart';
import 'package:tapto/features/onboarding/data/models/onboarding_model.dart';


void main() {
  testWidgets('OnboardingPageWidget displays title and description', (tester) async {
    const page = OnboardingModel(
      title: 'Welcome',
      description: 'This is onboarding',
      icon: Icons.star,
      backgroundColor: Colors.white,
      iconColor: Colors.black,
    );
    await tester.pumpWidget(MaterialApp(
      home: OnboardingPageWidget(page: page),
    ));
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('This is onboarding'), findsOneWidget);
  });
}