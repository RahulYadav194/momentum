import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:momentum/app/app.dart';
import 'package:momentum/app/router.dart';
import 'package:momentum/core/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Creates a [SharedPreferences] instance backed by [values].
///
/// The plugin is replaced with an in-memory store, so no platform channel is
/// involved and the result is deterministic.
Future<SharedPreferences> createTestPreferences(
  Map<String, Object> values,
) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

/// Builds the application under test with the given [preferences] injected.
///
/// A fresh [router] is created for every test, because a [GoRouter] keeps
/// navigation state that must not leak between tests.
///
/// Extra [overrides] are applied on top of the defaults, which lets widget
/// tests substitute fake repositories or streams.
Widget buildTestApp({
  required SharedPreferences preferences,
  GoRouter? router,
  List<dynamic> overrides = const <dynamic>[],
}) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      routerProvider.overrideWithValue(router ?? createRouter()),
      ...overrides,
    ],
    child: const MomentumApp(),
  );
}
