import 'alert_style.dart';
import 'arrival_target.dart';
import 'prayer.dart';

/// User-configurable timing settings that drive the leave-home calculation.
class TimingSettings {
  final int travelMinutes;
  final bool wuduEnabled;
  final int wuduMinutes;
  final bool bathroomEnabled;

  /// Minutes needed for the bathroom before each prayer. Per-prayer because
  /// needs differ (e.g. a longer routine before Fajr).
  final Map<Prayer, int> bathroomMinutes;
  final int safetyMarginMinutes;

  /// Minutes between adhan and iqama, per prayer.
  final Map<Prayer, int> iqamaOffsets;

  /// Whether the user wants to arrive by adhan or iqama, per prayer.
  final Map<Prayer, ArrivalTarget> arrivalTargets;

  /// How the leave-time alert presents itself.
  final AlertStyle alertStyle;

  /// On Fridays, treat Dhuhr as Jumu'ah: arrive before the adhan instead
  /// of targeting adhan/iqama (khutbah attendance and a good row).
  final bool jumuahEnabled;

  /// Minutes before the Jumu'ah adhan the user wants to be at the mosque.
  final int jumuahArriveEarlyMinutes;

  const TimingSettings({
    this.travelMinutes = 10,
    this.wuduEnabled = true,
    this.wuduMinutes = 1,
    this.bathroomEnabled = false,
    this.bathroomMinutes = defaultBathroomMinutes,
    this.safetyMarginMinutes = 0,
    this.iqamaOffsets = defaultIqamaOffsets,
    this.arrivalTargets = defaultArrivalTargets,
    this.alertStyle = AlertStyle.standard,
    this.jumuahEnabled = true,
    this.jumuahArriveEarlyMinutes = 20,
  });

  static const Map<Prayer, int> defaultBathroomMinutes = {
    Prayer.fajr: 3,
    Prayer.dhuhr: 3,
    Prayer.asr: 3,
    Prayer.maghrib: 3,
    Prayer.isha: 3,
  };

  static const Map<Prayer, int> defaultIqamaOffsets = {
    Prayer.fajr: 25,
    Prayer.dhuhr: 20,
    Prayer.asr: 20,
    Prayer.maghrib: 15,
    Prayer.isha: 20,
  };

  static const Map<Prayer, ArrivalTarget> defaultArrivalTargets = {
    Prayer.fajr: ArrivalTarget.iqama,
    Prayer.dhuhr: ArrivalTarget.iqama,
    Prayer.asr: ArrivalTarget.iqama,
    Prayer.maghrib: ArrivalTarget.iqama,
    Prayer.isha: ArrivalTarget.iqama,
  };

  /// Total minutes of preparation before travel (wudu, bathroom, margin)
  /// for the given prayer.
  int preparationMinutesFor(Prayer prayer) =>
      (wuduEnabled ? wuduMinutes : 0) +
      (bathroomEnabled ? (bathroomMinutes[prayer] ?? 0) : 0) +
      safetyMarginMinutes;

  TimingSettings copyWith({
    int? travelMinutes,
    bool? wuduEnabled,
    int? wuduMinutes,
    bool? bathroomEnabled,
    Map<Prayer, int>? bathroomMinutes,
    int? safetyMarginMinutes,
    Map<Prayer, int>? iqamaOffsets,
    Map<Prayer, ArrivalTarget>? arrivalTargets,
    AlertStyle? alertStyle,
    bool? jumuahEnabled,
    int? jumuahArriveEarlyMinutes,
  }) {
    return TimingSettings(
      travelMinutes: travelMinutes ?? this.travelMinutes,
      wuduEnabled: wuduEnabled ?? this.wuduEnabled,
      wuduMinutes: wuduMinutes ?? this.wuduMinutes,
      bathroomEnabled: bathroomEnabled ?? this.bathroomEnabled,
      bathroomMinutes: bathroomMinutes ?? this.bathroomMinutes,
      safetyMarginMinutes: safetyMarginMinutes ?? this.safetyMarginMinutes,
      iqamaOffsets: iqamaOffsets ?? this.iqamaOffsets,
      arrivalTargets: arrivalTargets ?? this.arrivalTargets,
      alertStyle: alertStyle ?? this.alertStyle,
      jumuahEnabled: jumuahEnabled ?? this.jumuahEnabled,
      jumuahArriveEarlyMinutes:
          jumuahArriveEarlyMinutes ?? this.jumuahArriveEarlyMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
        'travelMinutes': travelMinutes,
        'wuduEnabled': wuduEnabled,
        'wuduMinutes': wuduMinutes,
        'bathroomEnabled': bathroomEnabled,
        'bathroomMinutes':
            bathroomMinutes.map((p, v) => MapEntry(p.name, v)),
        'safetyMarginMinutes': safetyMarginMinutes,
        'iqamaOffsets':
            iqamaOffsets.map((p, v) => MapEntry(p.name, v)),
        'arrivalTargets':
            arrivalTargets.map((p, t) => MapEntry(p.name, t.name)),
        'alertStyle': alertStyle.name,
        'jumuahEnabled': jumuahEnabled,
        'jumuahArriveEarlyMinutes': jumuahArriveEarlyMinutes,
      };

  factory TimingSettings.fromJson(Map<String, dynamic> json) {
    return TimingSettings(
      travelMinutes: json['travelMinutes'] as int? ?? 10,
      wuduEnabled: json['wuduEnabled'] as bool? ?? true,
      wuduMinutes: json['wuduMinutes'] as int? ?? 1,
      bathroomEnabled: json['bathroomEnabled'] as bool? ?? false,
      bathroomMinutes: _bathroomMinutesFromJson(json['bathroomMinutes']),
      safetyMarginMinutes: json['safetyMarginMinutes'] as int? ?? 0,
      iqamaOffsets: (json['iqamaOffsets'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(Prayer.fromName(k), v as int)) ??
          defaultIqamaOffsets,
      arrivalTargets: (json['arrivalTargets'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(
                  Prayer.fromName(k), ArrivalTarget.fromName(v as String))) ??
          defaultArrivalTargets,
      alertStyle: AlertStyle.fromName(json['alertStyle'] as String? ?? ''),
      jumuahEnabled: json['jumuahEnabled'] as bool? ?? true,
      jumuahArriveEarlyMinutes:
          json['jumuahArriveEarlyMinutes'] as int? ?? 20,
    );
  }

  /// Accepts both the current per-prayer map and the legacy single int
  /// (earlier versions stored one value for all prayers).
  static Map<Prayer, int> _bathroomMinutesFromJson(Object? raw) {
    if (raw is int) {
      return {for (final p in Prayer.values) p: raw};
    }
    if (raw is Map<String, dynamic>) {
      return raw.map((k, v) => MapEntry(Prayer.fromName(k), v as int));
    }
    return defaultBathroomMinutes;
  }
}
