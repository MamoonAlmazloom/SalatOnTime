import 'alert_style.dart';
import 'arrival_target.dart';
import 'prayer.dart';

/// User-configurable timing settings that drive the leave-home calculation.
class TimingSettings {
  final int travelMinutes;
  final bool wuduEnabled;
  final int wuduMinutes;
  final bool bathroomEnabled;
  final int bathroomMinutes;
  final int safetyMarginMinutes;

  /// Minutes between adhan and iqama, per prayer.
  final Map<Prayer, int> iqamaOffsets;

  /// Whether the user wants to arrive by adhan or iqama, per prayer.
  final Map<Prayer, ArrivalTarget> arrivalTargets;

  /// How the leave-time alert presents itself.
  final AlertStyle alertStyle;

  const TimingSettings({
    this.travelMinutes = 10,
    this.wuduEnabled = true,
    this.wuduMinutes = 1,
    this.bathroomEnabled = false,
    this.bathroomMinutes = 3,
    this.safetyMarginMinutes = 0,
    this.iqamaOffsets = defaultIqamaOffsets,
    this.arrivalTargets = defaultArrivalTargets,
    this.alertStyle = AlertStyle.standard,
  });

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

  /// Total minutes of preparation before travel (wudu, bathroom, margin).
  int get preparationMinutes =>
      (wuduEnabled ? wuduMinutes : 0) +
      (bathroomEnabled ? bathroomMinutes : 0) +
      safetyMarginMinutes;

  TimingSettings copyWith({
    int? travelMinutes,
    bool? wuduEnabled,
    int? wuduMinutes,
    bool? bathroomEnabled,
    int? bathroomMinutes,
    int? safetyMarginMinutes,
    Map<Prayer, int>? iqamaOffsets,
    Map<Prayer, ArrivalTarget>? arrivalTargets,
    AlertStyle? alertStyle,
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
    );
  }

  Map<String, dynamic> toJson() => {
        'travelMinutes': travelMinutes,
        'wuduEnabled': wuduEnabled,
        'wuduMinutes': wuduMinutes,
        'bathroomEnabled': bathroomEnabled,
        'bathroomMinutes': bathroomMinutes,
        'safetyMarginMinutes': safetyMarginMinutes,
        'iqamaOffsets':
            iqamaOffsets.map((p, v) => MapEntry(p.name, v)),
        'arrivalTargets':
            arrivalTargets.map((p, t) => MapEntry(p.name, t.name)),
        'alertStyle': alertStyle.name,
      };

  factory TimingSettings.fromJson(Map<String, dynamic> json) {
    return TimingSettings(
      travelMinutes: json['travelMinutes'] as int? ?? 10,
      wuduEnabled: json['wuduEnabled'] as bool? ?? true,
      wuduMinutes: json['wuduMinutes'] as int? ?? 1,
      bathroomEnabled: json['bathroomEnabled'] as bool? ?? false,
      bathroomMinutes: json['bathroomMinutes'] as int? ?? 3,
      safetyMarginMinutes: json['safetyMarginMinutes'] as int? ?? 0,
      iqamaOffsets: (json['iqamaOffsets'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(Prayer.fromName(k), v as int)) ??
          defaultIqamaOffsets,
      arrivalTargets: (json['arrivalTargets'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(
                  Prayer.fromName(k), ArrivalTarget.fromName(v as String))) ??
          defaultArrivalTargets,
      alertStyle: AlertStyle.fromName(json['alertStyle'] as String? ?? ''),
    );
  }
}
