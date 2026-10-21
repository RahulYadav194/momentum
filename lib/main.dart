import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the preferences before the first frame so the application starts in
  // the theme the user selected, instead of flashing the wrong one.
  final SharedPreferences preferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      // Provider failures are programming errors in this app, so they are not
      // retried automatically.
      retry: (int retryCount, Object error) => null,
      child: const MomentumApp(),
    ),
  );
}
