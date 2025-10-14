CI guidelines for this Flutter project

- Tests that rely on platform plugins (example: flutter_secure_storage, shared_preferences) may fail when run under `dart test` on the VM.
- To reliably test code using platform channels, use flutter_test with the Flutter engine (`flutter test`) and consider using mock implementations or the `flutter_secure_storage` test utilities.
- The repository now includes a basic GitHub Actions workflow `.github/workflows/flutter-analyze.yml` that runs `flutter analyze` on push/PR to `main`.
- For full CI, consider adding steps to run `flutter test` in a matrix across channels (android, ios) or use `--platform chrome` for web tests where applicable.
