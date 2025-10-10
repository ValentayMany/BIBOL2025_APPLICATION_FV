// test/widgets/custom_bottom_nav_test.dart

import 'package:BIBOL/widgets/common/custom_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomBottomNav Tests', () {
    // Helper function to wrap widget with MaterialApp
    Widget makeTestableWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: Container(),
          bottomNavigationBar: child,
        ),
      );
    }

    testWidgets('should display all 5 navigation items', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          CustomBottomNav(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      // Assert
      expect(find.text('ໜ້າຫຼັກ'), findsOneWidget); // Home
      expect(find.text('ຂ່າວສານ'), findsOneWidget); // News
      expect(find.text('ຄັງຮູບ'), findsOneWidget); // Gallery
      expect(find.text('ກ່ຽວກັບ'), findsOneWidget); // About
      expect(find.text('ໂປຣໄຟລ'), findsOneWidget); // Profile
    });

    testWidgets('should display correct icons for each nav item', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          CustomBottomNav(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.home), findsOneWidget); // Active home icon
      expect(find.byIcon(Icons.article_outlined), findsOneWidget);
      expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('should highlight selected item (index 0)', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          CustomBottomNav(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      // Assert - should show active icon for selected item
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsNothing);
    });

    testWidgets('should highlight selected item (index 1)', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          CustomBottomNav(
            currentIndex: 1,
            onTap: (_) {},
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.article), findsOneWidget); // Active
      expect(find.byIcon(Icons.home_outlined), findsOneWidget); // Inactive
    });

    testWidgets('should highlight selected item (index 2)', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          CustomBottomNav(
            currentIndex: 2,
            onTap: (_) {},
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.photo_library), findsOneWidget);
    });

    testWidgets('should highlight selected item (index 3)', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          CustomBottomNav(
            currentIndex: 3,
            onTap: (_) {},
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.account_balance), findsOneWidget);
    });

    testWidgets('should highlight selected item (index 4)', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          CustomBottomNav(
            currentIndex: 4,
            onTap: (_) {},
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should call onTap with correct index when home is tapped', (tester) async {
      // Arrange
      int? tappedIndex;

      await tester.pumpWidget(
        makeTestableWidget(
          CustomBottomNav(
            currentIndex: 0,
            onTap: (index) {
              tappedIndex = index;
            },
          ),
        ),
      );

      // Act
      await tester.tap(find.text('ໜ້າຫຼັກ'));
      await tester.pumpAndSettle();

      // Assert
      expect(tappedIndex, equals(0));
    });

    testWidgets('should call onTap with correct index when news is tapped', (tester) async {
      // Arrange
      int? tappedIndex;

      await tester.pumpWidget(
        makeTestableWidget(
          CustomBottomNav(
            currentIndex: 0,
            onTap: (index) {
              tappedIndex = index;
            },
          ),
        ),
      );

      // Act
      await tester.tap(find.text('ຂ່າວສານ'));
      await tester.pumpAndSettle();

      // Assert
      expect(tappedIndex, equals(1));
    });

    testWidgets('should call onTap with correct index when gallery is tapped', (tester) async {
      // Arrange
      int? tappedIndex;

      await tester.pumpWidget(
        makeTestableWidget(
          CustomBottomNav(
            currentIndex: 0,
            onTap: (index) {
              tappedIndex = index;
            },
          ),
        ),
      );

      // Act
      await tester.tap(find.text('ຄັງຮູບ'));
      await tester.pumpAndSettle();

      // Assert
      expect(tappedIndex, equals(2));
    });

    testWidgets('should call onTap with correct index when about is tapped', (tester) async {
      // Arrange
      int? tappedIndex;

      await tester.pumpWidget(
        makeTestableWidget(
          CustomBottomNav(
            currentIndex: 0,
            onTap: (index) {
              tappedIndex = index;
            },
          ),
        ),
      );

      // Act
      await tester.tap(find.text('ກ່ຽວກັບ'));
      await tester.pumpAndSettle();

      // Assert
      expect(tappedIndex, equals(3));
    });

    testWidgets('should call onTap with correct index when profile is tapped', (tester) async {
      // Arrange
      int? tappedIndex;

      await tester.pumpWidget(
        makeTestableWidget(
          CustomBottomNav(
            currentIndex: 0,
            onTap: (index) {
              tappedIndex = index;
            },
          ),
        ),
      );

      // Act
      await tester.tap(find.text('ໂປຣໄຟລ'));
      await tester.pumpAndSettle();

      // Assert
      expect(tappedIndex, equals(4));
    });

    testWidgets('should have SafeArea widget', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          CustomBottomNav(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      // Assert
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('should have proper widget hierarchy', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          CustomBottomNav(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      // Assert
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Material), findsWidgets);
      expect(find.byType(InkWell), findsNWidgets(5)); // 5 nav items
    });

    testWidgets('should show active indicator for selected item', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          CustomBottomNav(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - AnimatedContainer should show indicator for active item
      final animatedContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      
      // There should be containers for indicators
      expect(animatedContainers.length, greaterThan(0));
    });

    testWidgets('should have animation controller', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          CustomBottomNav(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      // Assert
      final state = tester.state<State>(
        find.byType(CustomBottomNav),
      );
      
      expect(state, isA<SingleTickerProviderStateMixin>());
    });

    testWidgets('should update animation when currentIndex changes', (tester) async {
      // Arrange
      int currentIndex = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Container(),
                bottomNavigationBar: CustomBottomNav(
                  currentIndex: currentIndex,
                  onTap: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                ),
              ),
            );
          },
        ),
      );

      // Act - tap on news tab
      await tester.tap(find.text('ຂ່າວສານ'));
      await tester.pumpAndSettle();

      // Assert - should show active news icon
      expect(find.byIcon(Icons.article), findsOneWidget);
    });

    testWidgets('should have ink well effects', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          CustomBottomNav(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      // Assert
      final inkWells = tester.widgetList<InkWell>(
        find.byType(InkWell),
      );
      
      expect(inkWells.length, equals(5));
      
      for (final inkWell in inkWells) {
        expect(inkWell.splashColor, isNotNull);
        expect(inkWell.highlightColor, isNotNull);
        expect(inkWell.borderRadius, isNotNull);
      }
    });
  });
}
