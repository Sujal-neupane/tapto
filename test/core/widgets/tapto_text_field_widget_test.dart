import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapto/core/widgets/text_field_widget.dart';

void main() {
  // Widget Test 17: TaptoTextField renders hint text
  testWidgets('TaptoTextField should display hint text',
      (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaptoTextField(controller: controller, hint: 'Search...'),
        ),
      ),
    );

    expect(find.text('Search...'), findsOneWidget);
  });

  // Widget Test 18: TaptoTextField accepts input
  testWidgets('TaptoTextField should accept user input',
      (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaptoTextField(controller: controller, hint: 'Type here'),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'Hello World');
    expect(controller.text, 'Hello World');
  });

  // Widget Test 19: TaptoTextField validation shows error
  testWidgets('TaptoTextField validator should show error on empty input',
      (WidgetTester tester) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: TaptoTextField(
              controller: controller,
              hint: 'Enter name',
              validator: (value) {
                if (value == null || value.isEmpty) return 'Field is required';
                return null;
              },
            ),
          ),
        ),
      ),
    );

    formKey.currentState!.validate();
    await tester.pump();

    expect(find.text('Field is required'), findsOneWidget);
  });

  // Widget Test 20: TaptoTextField obscure text
  testWidgets('TaptoTextField should obscure text when obscure is true',
      (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaptoTextField(
            controller: controller,
            hint: 'Password',
            obscure: true,
          ),
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.obscureText, true);
  });
}
