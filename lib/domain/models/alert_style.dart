/// How the leave-time alert should present itself.
enum AlertStyle {
  /// A regular notification with the default notification sound.
  standard,

  /// Alarm-like: plays on the alarm audio channel (rings through silent
  /// mode on most Android devices) and shows full-screen when locked.
  alarm;

  static AlertStyle fromName(String name) => AlertStyle.values
      .firstWhere((s) => s.name == name, orElse: () => AlertStyle.standard);
}
