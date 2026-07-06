import 'package:flutter/material.dart';

/// App-wide theme mode, switchable from Settings and persisted via
/// SettingsRepository. MaterialApp listens to this notifier.
final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier(ThemeMode.system);

ThemeMode themeModeFromName(String? name) => switch (name) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

/// App-wide locale override. Null means "follow the system language".
final ValueNotifier<Locale?> localeNotifier = ValueNotifier(null);

Locale? localeFromName(String? name) => switch (name) {
      'ar' => const Locale('ar'),
      'en' => const Locale('en'),
      _ => null,
    };
