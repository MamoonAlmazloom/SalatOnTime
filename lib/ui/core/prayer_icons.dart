import 'package:flutter/material.dart';

import '../../domain/models/prayer.dart';

/// A distinctive icon per prayer, following the sun through the day.
IconData prayerIcon(Prayer prayer) => switch (prayer) {
      Prayer.fajr => Icons.wb_twilight,
      Prayer.dhuhr => Icons.light_mode,
      Prayer.asr => Icons.brightness_6,
      Prayer.maghrib => Icons.brightness_4,
      Prayer.isha => Icons.dark_mode,
    };
