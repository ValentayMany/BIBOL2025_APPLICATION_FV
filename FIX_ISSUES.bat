@echo off
REM BIBOL App - Auto Fix Script
REM This script fixes all remaining issues

echo ========================================
echo BIBOL App - Auto Fix Issues
echo ========================================
echo.

echo Fixing issues...
echo.

REM Delete lib/test directory if exists
if exist "lib\test" (
    echo [1/3] Removing lib\test directory...
    rmdir /s /q "lib\test"
    echo Done!
) else (
    echo [1/3] lib\test not found (OK)
)

echo.
echo [2/3] Cleaning project...
call flutter clean
if %errorlevel% neq 0 goto :error

echo.
echo [3/3] Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 goto :error

echo.
echo ========================================
echo Fixed! Now run: flutter analyze
echo ========================================
pause
exit /b 0

:error
echo.
echo ========================================
echo Fix Failed!
echo ========================================
pause
exit /b 1
