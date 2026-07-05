import 'package:salat_app/l10n/app_localizations.dart';

import '../../domain/models/prayer.dart';

/// Localized display name for a prayer.
String prayerName(AppLocalizations l10n, Prayer prayer) => switch (prayer) {
      Prayer.fajr => l10n.prayerFajr,
      Prayer.dhuhr => l10n.prayerDhuhr,
      Prayer.asr => l10n.prayerAsr,
      Prayer.maghrib => l10n.prayerMaghrib,
      Prayer.isha => l10n.prayerIsha,
    };
