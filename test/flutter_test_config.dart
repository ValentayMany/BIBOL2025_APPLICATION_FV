import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Disable Google Fonts HTTP fetching globally
  GoogleFonts.config.allowRuntimeFetching = false;

  await testMain();
}
