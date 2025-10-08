@echo off
REM BIBOL App - Test Runner for Windows
REM This script runs tests safely on Windows

echo ========================================
echo BIBOL App - Running Tests
echo ========================================
echo.

echo [1/4] Cleaning project...
call flutter clean
if %errorlevel% neq 0 goto :error

echo.
echo [2/4] Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 goto :error

echo.
echo [3/4] Running code analysis...
call flutter analyze
if %errorlevel% neq 0 goto :error

echo.
echo [4/4] Running unit tests...
echo.

echo Running Validators Tests...
call flutter test test/utils/validators_test.dart --no-test-assets
if %errorlevel% neq 0 goto :error

echo.
echo Running Secure Storage Tests...
call flutter test test/services/secure_storage_service_test.dart --no-test-assets
if %errorlevel% neq 0 goto :error

echo.
echo ========================================
echo All Tests Passed! ✓
echo ========================================
goto :end

:error
echo.
echo ========================================
echo Tests Failed! ✗
echo ========================================
exit /b 1

:end
echo.
echo Done!
pause
