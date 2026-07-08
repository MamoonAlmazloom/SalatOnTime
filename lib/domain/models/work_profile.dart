import 'mosque.dart';
import 'prayer.dart';

/// A second prayer place (work/school): its own mosque and travel time,
/// applied to selected prayers on selected weekdays. Schedule-based by
/// design — no background location, matching the app's privacy stance.
class WorkProfile {
  final bool enabled;

  /// The mosque near the second place; null until the user picks one.
  final Mosque? mosque;
  final int travelMinutes;

  /// Weekdays the profile is active ([DateTime.monday]..[DateTime.sunday]).
  final Set<int> weekdays;

  /// Prayers prayed at this place on active days.
  final Set<Prayer> prayers;

  const WorkProfile({
    this.enabled = false,
    this.mosque,
    this.travelMinutes = 10,
    this.weekdays = defaultWeekdays,
    this.prayers = defaultPrayers,
  });

  /// Sunday–Thursday: the working week where this app's audience lives.
  static const Set<int> defaultWeekdays = {
    DateTime.sunday,
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
  };

  static const Set<Prayer> defaultPrayers = {Prayer.dhuhr, Prayer.asr};

  /// Whether this profile governs [prayer] on the given [weekday].
  bool appliesTo({required int weekday, required Prayer prayer}) =>
      enabled &&
      mosque != null &&
      weekdays.contains(weekday) &&
      prayers.contains(prayer);

  WorkProfile copyWith({
    bool? enabled,
    Mosque? mosque,
    bool clearMosque = false,
    int? travelMinutes,
    Set<int>? weekdays,
    Set<Prayer>? prayers,
  }) {
    return WorkProfile(
      enabled: enabled ?? this.enabled,
      mosque: clearMosque ? null : (mosque ?? this.mosque),
      travelMinutes: travelMinutes ?? this.travelMinutes,
      weekdays: weekdays ?? this.weekdays,
      prayers: prayers ?? this.prayers,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        if (mosque != null) 'mosque': mosque!.toJson(),
        'travelMinutes': travelMinutes,
        'weekdays': weekdays.toList(),
        'prayers': prayers.map((p) => p.name).toList(),
      };

  factory WorkProfile.fromJson(Map<String, dynamic> json) {
    return WorkProfile(
      enabled: json['enabled'] as bool? ?? false,
      mosque: json['mosque'] == null
          ? null
          : Mosque.fromJson(json['mosque'] as Map<String, dynamic>),
      travelMinutes: json['travelMinutes'] as int? ?? 10,
      weekdays: (json['weekdays'] as List?)?.cast<int>().toSet() ??
          defaultWeekdays,
      prayers: (json['prayers'] as List?)
              ?.cast<String>()
              .map(Prayer.fromName)
              .toSet() ??
          defaultPrayers,
    );
  }
}
