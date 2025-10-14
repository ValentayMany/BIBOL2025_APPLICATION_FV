// test/helpers/shared_prefs_helpers.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Initialize SharedPreferences with in-memory mock values for tests
void setupMockSharedPreferences([Map<String, Object>? initialValues]) {
  SharedPreferences.setMockInitialValues(initialValues ?? <String, Object>{});
}

/// Clear SharedPreferences mock (resets to empty)
void tearDownMockSharedPreferences() {
  SharedPreferences.setMockInitialValues(<String, Object>{});
}
