# BIBOL App - Test Runner for Windows (PowerShell)
# Run this with: powershell -ExecutionPolicy Bypass -File run_tests.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "BIBOL App - Running Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to run command and check result
function Run-Command {
    param($Command, $Description)
    Write-Host $Description -ForegroundColor Yellow
    Invoke-Expression $Command
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Red
        Write-Host "Failed: $Description" -ForegroundColor Red
        Write-Host "========================================" -ForegroundColor Red
        exit 1
    }
    Write-Host ""
}

# Clean
Run-Command "flutter clean" "[1/4] Cleaning project..."

# Get dependencies
Run-Command "flutter pub get" "[2/4] Getting dependencies..."

# Analyze
Run-Command "flutter analyze" "[3/4] Running code analysis..."

Write-Host "[4/4] Running unit tests..." -ForegroundColor Yellow
Write-Host ""

# Run Validators Tests
Write-Host "Running Validators Tests..." -ForegroundColor Green
flutter test test/utils/validators_test.dart --no-test-assets
if ($LASTEXITCODE -ne 0) {
    Write-Host "Validators tests failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Running Secure Storage Tests..." -ForegroundColor Green
flutter test test/services/secure_storage_service_test.dart --no-test-assets
if ($LASTEXITCODE -ne 0) {
    Write-Host "Secure Storage tests failed!" -ForegroundColor Red
    exit 1
}

# Success
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "All Tests Passed! ✓" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
