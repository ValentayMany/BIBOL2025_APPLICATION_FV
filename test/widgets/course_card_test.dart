// test/widgets/course_card_test.dart

import 'package:BIBOL/models/course/course_model.dart';
import 'package:BIBOL/widgets/home_widgets/course_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../google_fonts_test_helper.dart';

void main() {
  // Initialize Google Fonts for testing
  GoogleFontsTestHelper.initialize();
  group('CourseCardWidget Tests', () {
    // Helper function to create a test course
    CourseModel createTestCourse({
      int id = 1,
      String title = 'Test Course',
      String? description,
      String? icon,
    }) {
      return CourseModel(
        id: id,
        title: title,
        description: description,
        icon: icon,
        details: '',
      );
    }

    // Helper function to wrap widget with MaterialApp
    Widget makeTestableWidget(Widget child) {
      return GoogleFontsTestHelper.createTestWidget(child);
    }

    testWidgets('should display course title correctly', (tester) async {
      // Arrange
      final course = createTestCourse(title: 'Introduction to Flutter');

      // Act
      await tester.pumpWidget(
        makeTestableWidget(CourseCardWidget(course: course, screenWidth: 375)),
      );

      // Assert
      expect(find.text('Introduction to Flutter'), findsOneWidget);
    });

    testWidgets(
      'should display default graduation cap icon when no icon provided',
      (tester) async {
        // Arrange
        final course = createTestCourse(icon: null);

        // Act
        await tester.pumpWidget(
          makeTestableWidget(
            CourseCardWidget(course: course, screenWidth: 375),
          ),
        );

        // Assert
        expect(find.byIcon(FontAwesomeIcons.graduationCap), findsOneWidget);
      },
    );

    testWidgets('should display "recommended" badge', (tester) async {
      // Arrange
      final course = createTestCourse();

      // Act
      await tester.pumpWidget(
        makeTestableWidget(CourseCardWidget(course: course, screenWidth: 375)),
      );

      // Assert
      expect(find.text('ແນະນຳ'), findsOneWidget); // "Recommended" in Lao
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      // Arrange
      final course = createTestCourse();
      bool wasTapped = false;

      // Act
      await tester.pumpWidget(
        makeTestableWidget(
          CourseCardWidget(
            course: course,
            screenWidth: 375,
            onTap: () {
              wasTapped = true;
            },
          ),
        ),
      );

      await tester.tap(find.byType(CourseCardWidget));
      await tester.pumpAndSettle();

      // Assert
      expect(wasTapped, isTrue);
    });

    testWidgets('should display "view details" button', (tester) async {
      // Arrange
      final course = createTestCourse();

      // Act
      await tester.pumpWidget(
        makeTestableWidget(CourseCardWidget(course: course, screenWidth: 375)),
      );

      // Assert
      expect(
        find.text('ເບິ່ງລາຍລະອຽດ'),
        findsOneWidget,
      ); // "View details" in Lao
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('should handle long course titles with ellipsis', (
      tester,
    ) async {
      // Arrange
      final course = createTestCourse(
        title:
            'This is a very long course title that should be truncated with an ellipsis when displayed',
      );

      // Act
      await tester.pumpWidget(
        makeTestableWidget(CourseCardWidget(course: course, screenWidth: 375)),
      );

      // Assert
      expect(find.byType(CourseCardWidget), findsOneWidget);
      // Text widget should have overflow property set to ellipsis
      final textWidget = tester.widget<Text>(find.text(course.title));
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });

    testWidgets('should adapt layout for extra small screens', (tester) async {
      // Arrange
      final course = createTestCourse(title: 'Small Screen Test');

      // Act
      await tester.pumpWidget(
        makeTestableWidget(
          CourseCardWidget(
            course: course,
            screenWidth: 320, // Extra small screen
          ),
        ),
      );

      // Assert
      expect(find.text('Small Screen Test'), findsOneWidget);
      expect(find.byType(CourseCardWidget), findsOneWidget);
    });

    testWidgets('should adapt layout for tablets', (tester) async {
      // Arrange
      final course = createTestCourse(title: 'Tablet Test');

      // Act
      await tester.pumpWidget(
        makeTestableWidget(
          CourseCardWidget(
            course: course,
            screenWidth: 768, // Tablet size
          ),
        ),
      );

      // Assert
      expect(find.text('Tablet Test'), findsOneWidget);
      expect(find.byType(CourseCardWidget), findsOneWidget);
    });

    testWidgets('should have gradient background', (tester) async {
      // Arrange
      final course = createTestCourse();

      // Act
      await tester.pumpWidget(
        makeTestableWidget(CourseCardWidget(course: course, screenWidth: 375)),
      );

      // Assert
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
    });

    testWidgets('should have proper widget hierarchy', (tester) async {
      // Arrange
      final course = createTestCourse();

      // Act
      await tester.pumpWidget(
        makeTestableWidget(CourseCardWidget(course: course, screenWidth: 375)),
      );

      // Assert
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Material), findsWidgets);
      expect(find.byType(InkWell), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should handle invalid icon URLs gracefully', (tester) async {
      // Arrange
      final course = createTestCourse(icon: 'invalid-url');

      // Act
      await tester.pumpWidget(
        makeTestableWidget(CourseCardWidget(course: course, screenWidth: 375)),
      );
      await tester.pump();

      // Assert - should still render without errors
      expect(find.byType(CourseCardWidget), findsOneWidget);
      expect(find.byIcon(FontAwesomeIcons.graduationCap), findsOneWidget);
    });

    testWidgets('should have box shadow for depth', (tester) async {
      // Arrange
      final course = createTestCourse();

      // Act
      await tester.pumpWidget(
        makeTestableWidget(CourseCardWidget(course: course, screenWidth: 375)),
      );

      // Assert
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.isNotEmpty, isTrue);
    });

    testWidgets('should render button with gradient background', (
      tester,
    ) async {
      // Arrange
      final course = createTestCourse();

      // Act
      await tester.pumpWidget(
        makeTestableWidget(CourseCardWidget(course: course, screenWidth: 375)),
      );

      // Assert
      final containers = tester.widgetList<Container>(find.byType(Container));

      // Check that there's a container with gradient
      final hasGradient = containers.any((container) {
        final decoration = container.decoration;
        if (decoration is BoxDecoration) {
          return decoration.gradient != null;
        }
        return false;
      });

      expect(hasGradient, isTrue);
    });
  });
}
