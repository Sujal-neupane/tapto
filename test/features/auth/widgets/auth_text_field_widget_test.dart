import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapto/features/auth/presentation/widgets/auth_text_field.dart';

void main() {
  // Widget Test 8: AuthTextField renders label and hint
  testWidgets('AuthTextField should display label and hint text',
      (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthTextField(
            controller: controller,
            label: 'Email',
            hint: 'Enter your email',
            prefixIcon: Icons.email,
          ),
        ),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Enter your email'), findsOneWidget);
  });

  // Widget Test 9: AuthTextField accepts text input
  testWidgets('AuthTextField should accept and display typed text',
      (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthTextField(
            controller: controller,
            label: 'Name',
            hint: 'Enter name',
            prefixIcon: Icons.person,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'John Doe');
    expect(controller.text, 'John Doe');
  });

  // Widget Test 10: AuthTextField obscures text when obscureText is true
  testWidgets('AuthTextField should obscure text when obscureText is true',
      (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthTextField(
            controller: controller,
            label: 'Password',
            hint: 'Enter password',
            prefixIcon: Icons.lock,
            obscureText: true,
          ),
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.obscureText, true);
  });

  // Widget Test 11: AuthTextField shows prefix icon
  testWidgets('AuthTextField should show the prefix icon',
      (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthTextField(
            controller: controller,
            label: 'Phone',
            hint: 'Enter phone',
            prefixIcon: Icons.phone,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.phone), findsOneWidget);
  });

  // Widget Test 12: AuthTextField validation works
  testWidgets('AuthTextField validator should show error message',
      (WidgetTester tester) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: AuthTextField(
              controller: controller,
              label: 'Email',
              hint: 'Enter email',
              prefixIcon: Icons.email,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Email is required';
                return null;
              },
            ),
          ),
        ),
      ),
    );

    // Validate the form with empty input
    formKey.currentState!.validate();
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
  });

  // Widget Test 13: AuthTextField with suffixIcon
  testWidgets('AuthTextField should show suffix icon when provided',
      (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthTextField(
            controller: controller,
            label: 'Password',
            hint: 'Enter password',
            prefixIcon: Icons.lock,
            obscureText: true,
            suffixIcon: const Icon(Icons.visibility_off),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });
}
