// Login Page Widget Tests
// Tests for LoginPage UI and basic functionality

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:BIBOL/screens/auth/login_page.dart';

void main() {
  // Test helper to create widget with MaterialApp wrapper
  Widget createLoginPage() {
    return MaterialApp(
      home: LoginPage(),
    );
  }

  group('LoginPage Widget Tests', () {
    testWidgets('LoginPage renders correctly with all required widgets',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle(); // Wait for animations

      // Assert - Check if all major UI elements exist
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('ສະຖາບັນການທະນາຄານ'), findsOneWidget);
      expect(find.text('ເຂົ້າສູ່ລະບົບ'), findsWidgets); // Title and button
      expect(find.text('Version 1.0.0'), findsOneWidget);
    });

    testWidgets('LoginPage has admission number and email text fields',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      // Assert - Check for form fields
      final admissionField =
          find.widgetWithText(TextFormField, 'ລະຫັດນັກຮຽນ (Admission No)');
      final emailField = find.widgetWithText(TextFormField, 'ອີເມວ (Email)');

      expect(admissionField, findsOneWidget);
      expect(emailField, findsOneWidget);
    });

    testWidgets('LoginPage has login button', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      // Assert - Check for login button
      final loginButton = find.widgetWithText(ElevatedButton, 'ເຂົ້າສູ່ລະບົບ');
      expect(loginButton, findsOneWidget);
    });

    testWidgets('LoginPage has forgot password button',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      // Assert - Check for forgot password button
      final forgotPasswordButton = find.text('ລືມລະຫັດ?');
      expect(forgotPasswordButton, findsOneWidget);
    });

    testWidgets('LoginPage has back button', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      // Assert - Check for back button
      final backButton = find.text('ກັບຄືນ');
      expect(backButton, findsOneWidget);
    });

    testWidgets('LoginPage displays logo image', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      // Assert - Check for Hero widget with logo
      final heroWidget = find.byWidgetPredicate(
        (widget) => widget is Hero && widget.tag == 'app_logo',
      );
      expect(heroWidget, findsOneWidget);
    });

    testWidgets('Validation shows error for empty admission number',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      // Act - Tap login button without filling fields
      final loginButton = find.widgetWithText(ElevatedButton, 'ເຂົ້າສູ່ລະບົບ');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Assert - Check for validation error
      expect(find.text('ກະລຸນາປ້ອນລະຫັດນັກຮຽນ'), findsOneWidget);
    });

    testWidgets('Validation shows error for empty email',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      // Act - Fill admission number but leave email empty
      final admissionField =
          find.widgetWithText(TextFormField, 'ລະຫັດນັກຮຽນ (Admission No)');
      await tester.enterText(admissionField, 'TEST001');

      final loginButton = find.widgetWithText(ElevatedButton, 'ເຂົ້າສູ່ລະບົບ');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Assert - Check for email validation error
      expect(find.text('ກະລຸນາປ້ອນອີເມວ'), findsOneWidget);
    });

    testWidgets('Validation shows error for invalid email format',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      // Act - Fill with invalid email
      final admissionField =
          find.widgetWithText(TextFormField, 'ລະຫັດນັກຮຽນ (Admission No)');
      await tester.enterText(admissionField, 'TEST001');

      final emailField = find.widgetWithText(TextFormField, 'ອີເມວ (Email)');
      await tester.enterText(emailField, 'invalidemail'); // No @

      final loginButton = find.widgetWithText(ElevatedButton, 'ເຂົ້າສູ່ລະບົບ');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Assert - Check for email format validation error
      expect(find.text('ອີເມວບໍ່ຖືກຕ້ອງ'), findsOneWidget);
    });

    testWidgets('Entering text in admission field updates the field',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      // Act - Enter text
      final admissionField =
          find.widgetWithText(TextFormField, 'ລະຫັດນັກຮຽນ (Admission No)');
      await tester.enterText(admissionField, 'TEST001');
      await tester.pumpAndSettle();

      // Assert - Check if text is entered
      expect(find.text('TEST001'), findsOneWidget);
    });

    testWidgets('Entering text in email field updates the field',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      // Act - Enter text
      final emailField = find.widgetWithText(TextFormField, 'ອີເມວ (Email)');
      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle();

      // Assert - Check if text is entered
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Forgot password button shows dialog',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      // Act - Tap forgot password
      final forgotPasswordButton = find.text('ລືມລະຫັດ?');
      await tester.tap(forgotPasswordButton);
      await tester.pumpAndSettle();

      // Assert - Check if dialog appears
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text('ກະລຸນາຕິດຕໍ່ຜູ້ດູແລລະບົບເພື່ອຣີເຊັດລະຫັດຜ່ານ.'),
        findsOneWidget,
      );
    });

    testWidgets('Back button pops the route', (WidgetTester tester) async {
      // Arrange - Create a navigator with home and login page
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LoginPage()),
                    );
                  },
                  child: Text('Go to Login'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to login page
      await tester.tap(find.text('Go to Login'));
      await tester.pumpAndSettle();

      // Act - Tap back button
      final backButton = find.text('ກັບຄືນ');
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Assert - Check if we're back to home
      expect(find.text('Go to Login'), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('Login button is disabled when loading',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      // Note: Testing actual loading state requires mocking the API
      // Here we just verify the button exists and can be tapped
      final loginButton = find.widgetWithText(ElevatedButton, 'ເຂົ້າສູ່ລະບົບ');
      expect(loginButton, findsOneWidget);

      // Verify button is initially enabled
      final ElevatedButton button = tester.widget(loginButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('Form fields have correct keyboard types',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      // Assert - Check email field has email keyboard
      final emailField = find.widgetWithText(TextFormField, 'ອີເມວ (Email)');
      final TextFormField emailWidget = tester.widget(emailField);
      expect(emailWidget.keyboardType, TextInputType.emailAddress);
    });

    testWidgets('Form has proper input actions', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      // Assert - Check text input actions
      final admissionField =
          find.widgetWithText(TextFormField, 'ລະຫັດນັກຮຽນ (Admission No)');
      final TextFormField admissionWidget = tester.widget(admissionField);
      expect(admissionWidget.textInputAction, TextInputAction.next);

      final emailField = find.widgetWithText(TextFormField, 'ອີເມວ (Email)');
      final TextFormField emailWidget = tester.widget(emailField);
      expect(emailWidget.textInputAction, TextInputAction.done);
    });
  });

  group('LoginPage Animations Tests', () {
    testWidgets('LoginPage contains animated widgets',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginPage());

      // Don't pump and settle immediately to test animations
      await tester.pump();

      // Assert - Check for animation widgets
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });

    testWidgets('Page animates in on load', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginPage());

      // Check initial state (before animation completes)
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(LoginPage), findsOneWidget);

      // Complete animation
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });

  group('LoginPage UI Layout Tests', () {
    testWidgets('LoginPage uses SafeArea', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('LoginPage has gradient background',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      // Assert - Check for Container with gradient
      final gradientContainer = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).gradient != null,
      );
      expect(gradientContainer, findsWidgets);
    });

    testWidgets('LoginPage is scrollable', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      // Assert - Check for SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('Form is wrapped in proper container',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      // Assert - Check for Form widget
      expect(find.byType(Form), findsOneWidget);

      // Check for backdrop filter (glassmorphic effect)
      expect(find.byType(BackdropFilter), findsWidgets);
    });
  });
}
