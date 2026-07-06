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
