@echo off
echo Running Flutter Tests with Google Fonts Fix...
echo.

echo Testing basic widget test...
flutter test test/widget_test.dart

echo.
echo Testing news card widget...
flutter test test/widgets/news_card_test.dart

echo.
echo Testing course card widget...
flutter test test/widgets/course_card_test.dart

echo.
echo Testing custom bottom nav...
flutter test test/widgets/custom_bottom_nav_test.dart

echo.
echo All tests completed!
pause
