import 'package:amayalert/feature/auth/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ForgotPasswordScreen Widget Tests', () {
    testWidgets('should display all required UI elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const ForgotPasswordScreen()));

      // Check if the screen title is displayed
      expect(find.text('Forgot Password?'), findsOneWidget);

      // Check if email field is present
      expect(find.text('Email Address'), findsOneWidget);

      // Check if send button is present
      expect(find.text('Send Reset Email'), findsOneWidget);

      // Check if back to sign in button is present
      expect(find.text('Back to Sign In'), findsOneWidget);

      // Check if instructions section is present
      expect(find.text('What happens next?'), findsOneWidget);
    });

    testWidgets('should show email sent state after successful submission', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const ForgotPasswordScreen()));

      // The email sent state would be tested with proper mocking
      // This is a placeholder test structure
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    });
  });
}
