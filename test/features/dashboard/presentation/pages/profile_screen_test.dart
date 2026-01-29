import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'package:tapto/features/dashboard/presentation/pages/profile_screen.dart';


void main() {
  testWidgets('ProfileScreen shows default user info', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(null), 
        ],
        child: MaterialApp(home: ProfileScreen()),
      ),
    );
    expect(find.text('Guest User'), findsOneWidget);
    expect(find.text('guest@tapto.com'), findsOneWidget);
  });
}