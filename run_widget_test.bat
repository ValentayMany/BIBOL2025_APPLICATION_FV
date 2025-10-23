@echo off
echo Running widget test...
flutter test test/widget_test.dart
if %errorlevel% neq 0 (
    echo Test failed with error code %errorlevel%
) else (
    echo Test passed successfully!
)
pause
