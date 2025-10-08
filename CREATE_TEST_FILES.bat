@echo off
REM Create test directories and files

echo Creating test directory structure...

REM Create directories
if not exist "test\utils" mkdir test\utils
if not exist "test\services" mkdir test\services

echo Created test directories!
echo.
echo Now copy these files:
echo 1. VALIDATORS_TEST.dart -> test\utils\validators_test.dart
echo 2. SECURE_STORAGE_TEST.dart -> test\services\secure_storage_service_test.dart
echo.
pause
