import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:salat_app/l10n/app_localizations.dart';

import '../../../../data/repositories/settings_repository.dart';
import '../../../../data/services/notification_service.dart';
import '../../../../domain/models/prayer_timing.dart';
import '../../../../domain/use_cases/next_prayer_resolver.dart';
import '../../../core/alert_messages.dart';
import '../../../core/app_theme.dart';
import '../../../core/prayer_icons.dart';
import '../../../core/prayer_names.dart';
import '../../../core/widgets/app_emblem.dart';
import '../../../core/widgets/section_title.dart';
import '../../settings/views/settings_screen.dart';
import '../view_models/home_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.notificationService});

  /// Injectable so the app can pass the instance initialized in main().
  final NotificationService? notificationService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _viewModel = HomeViewModel(
      repository: SettingsRepository(),
      notifications: widget.notificationService ?? NotificationService.instance,
    )..load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back from the system settings screen: re-check permissions so
    // the notifications-off warning disappears as soon as it is fixed.
    if (state == AppLifecycleState.resumed) {
      _viewModel.recheckNotificationsEnabled();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    _viewModel.notificationTexts = NotificationTexts(
      build: (timing, seed) => AlertMessages.pick(
        languageCode: languageCode,
        seed: seed,
        prayerName: timingName(l10n, timing),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
    await _viewModel.refresh();
  }

  /// Whether the hero is currently counting down to Jumu'ah at a dedicated
  /// Jumu'ah mosque (name + travel in the hero then refer to that mosque).
  bool get _heroShowsJumuah =>
      _viewModel.status?.timing.isJumuah == true &&
      _viewModel.jumuahMosque != null;

  /// Whether the hero counts down to a prayer at the work/school place.
  bool get _heroShowsWork =>
      _viewModel.status?.timing.isWork == true &&
      _viewModel.workProfile.mosque != null;

  int get _heroTravelMinutes => _heroShowsJumuah
      ? (_viewModel.settings.jumuahTravelMinutes ??
          _viewModel.settings.travelMinutes)
      : _heroShowsWork
          ? _viewModel.workProfile.travelMinutes
          : _viewModel.settings.travelMinutes;

  String? get _heroMosqueName => _heroShowsJumuah
      ? _viewModel.jumuahMosque?.name
      : _heroShowsWork
          ? _viewModel.workProfile.mosque?.name
          : _viewModel.mosque?.name;

  Future<void> _editTravelTime() async {
    final l10n = AppLocalizations.of(context)!;
    final editingJumuah = _heroShowsJumuah;
    final editingWork = _heroShowsWork;
    final controller = TextEditingController(text: '$_heroTravelMinutes');
    final minutes = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.travelMinutesLabel),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text)),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (minutes != null) {
      if (editingJumuah) {
        await _viewModel.updateJumuahTravelMinutes(minutes);
      } else if (editingWork) {
        await _viewModel.updateWorkTravelMinutes(minutes);
      } else {
        await _viewModel.updateTravelMinutes(minutes);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // The hero gradient sits behind the status bar, so its icons stay white.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            if (_viewModel.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            final status = _viewModel.status;
            return Column(
              children: [
                _HeroHeader(
                  status: status,
                  mosqueName: _heroMosqueName,
                  travelMinutes: _heroTravelMinutes,
                  hijriAdjustment: _viewModel.hijriAdjustment,
                  onEditTravel: _editTravelTime,
                  onOpenSettings: _openSettings,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    children: [
                      if (_viewModel.notificationsOff) ...[
                        const _NotificationsOffCard(),
                        const SizedBox(height: 16),
                      ],
                      SectionTitle(l10n.todaysPrayers),
                      for (final timing in _viewModel.today)
                        _PrayerRow(
                          timing: timing,
                          isNext: status?.timing.prayer == timing.prayer &&
                              status?.timing.adhanTime == timing.adhanTime,
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Full-bleed gradient hero: brand row, dates, mosque glass panel, and the
/// live leave-home countdown — the privacy-page header brought into the app.
class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.status,
    required this.mosqueName,
    required this.travelMinutes,
    required this.hijriAdjustment,
    required this.onEditTravel,
    required this.onOpenSettings,
  });

  final NextPrayerStatus? status;
  final String? mosqueName;
  final int travelMinutes;
  final int hijriAdjustment;
  final VoidCallback onEditTravel;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    HijriCalendar.language = locale == 'ar' ? 'ar' : 'en';
    // User calibration: the astronomical estimate can drift a day or two
    // from the official (sighting-based) calendar.
    final hijri =
        HijriCalendar.fromDate(now.add(Duration(days: hijriAdjustment)));
    final onHeroFaded = Colors.white.withValues(alpha: 0.7);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient(theme.colorScheme),
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.seed.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.paddingOf(context).top + 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppEmblem(size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.appTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                color: Colors.white,
                onPressed: onOpenSettings,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hijri.toFormat('dd MMMM yyyy'),
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            DateFormat.yMMMMEEEEd(locale).format(now),
            style: theme.textTheme.bodyMedium?.copyWith(color: onHeroFaded),
          ),
          if (mosqueName != null) ...[
            const SizedBox(height: 14),
            _GlassPanel(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.mosque, size: 18, color: AppTheme.gold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      mosqueName!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _TravelPill(
                    minutes: travelMinutes,
                    unit: l10n.minutesShort,
                    onTap: onEditTravel,
                  ),
                ],
              ),
            ),
          ],
          if (status != null) ...[
            const SizedBox(height: 18),
            _HeroCountdown(status: status!),
          ],
        ],
      ),
    );
  }
}

class _HeroCountdown extends StatelessWidget {
  const _HeroCountdown({required this.status});

  final NextPrayerStatus status;

  String _countdown(Duration d) {
    final t = d.isNegative ? Duration.zero : d;
    final h = t.inHours;
    final m = t.inMinutes.remainder(60);
    final s = t.inSeconds.remainder(60);
    String two(int v) => v.toString().padLeft(2, '0');
    return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final clock = DateFormat.jm(Localizations.localeOf(context).languageCode);

    final leave = status.untilLeave;
    final leaveOverdue = leave.isNegative;
    final leaveSoon = !leaveOverdue && leave <= const Duration(minutes: 5);
    final accent = leaveOverdue
        ? const Color(0xFFFF8A80)
        : leaveSoon
            ? AppTheme.gold
            : Colors.white;
    final onHeroFaded = Colors.white.withValues(alpha: 0.7);

    return Column(
      children: [
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(timingIcon(status.timing), color: onHeroFaded, size: 22),
              const SizedBox(width: 8),
              Text(
                timingName(l10n, status.timing),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          leaveOverdue ? l10n.leaveNow : l10n.leaveIn,
          style: theme.textTheme.titleMedium?.copyWith(
            color: accent,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          leaveOverdue ? '00:00' : _countdown(leave),
          style: theme.textTheme.displayLarge?.copyWith(
            color: accent,
            fontWeight: FontWeight.w700,
            fontSize: 60,
            height: 1.1,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          clock.format(status.timing.leaveTime),
          style: theme.textTheme.bodyMedium?.copyWith(color: onHeroFaded),
        ),
        const SizedBox(height: 14),
        _GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              _CountdownRow(
                label: status.untilAdhan.isNegative
                    ? l10n.adhanPassed
                    : l10n.adhanIn,
                countdown: status.untilAdhan.isNegative
                    ? null
                    : _countdown(status.untilAdhan),
                time: clock.format(status.timing.adhanTime),
              ),
              const SizedBox(height: 8),
              _CountdownRow(
                label: l10n.iqamaIn,
                countdown: _countdown(status.untilIqama),
                time: clock.format(status.timing.iqamaTime),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Urgent, tappable warning shown when the app is not allowed to post
/// notifications — without them the core leave-time alert cannot work.
class _NotificationsOffCard extends StatelessWidget {
  const _NotificationsOffCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.error.withValues(alpha: 0.35)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_off, color: scheme.error),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.notifOffTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onErrorContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.notifOffBody,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: scheme.onErrorContainer),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: () => AppSettings.openAppSettings(
                  type: AppSettingsType.notification),
              icon: const Icon(Icons.notifications_active),
              label: Text(l10n.notifOffButton),
            ),
          ),
        ],
      ),
    );
  }
}

/// White ~10% alpha panel used on the hero gradient (design language).
class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: child,
    );
  }
}

class _TravelPill extends StatelessWidget {
  const _TravelPill({
    required this.minutes,
    required this.unit,
    required this.onTap,
  });

  final int minutes;
  final String unit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.directions_walk,
                  size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                '$minutes $unit',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.edit,
                  size: 12, color: Colors.white.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountdownRow extends StatelessWidget {
  const _CountdownRow({
    required this.label,
    required this.countdown,
    required this.time,
  });

  final String label;
  final String? countdown;
  final String time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final faded = Colors.white.withValues(alpha: 0.7);
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: theme.textTheme.bodyLarge?.copyWith(color: faded)),
        ),
        if (countdown != null)
          Text(
            countdown!,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        const SizedBox(width: 12),
        Text(time, style: theme.textTheme.bodyMedium?.copyWith(color: faded)),
      ],
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({required this.timing, required this.isNext});

  final PrayerTiming timing;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final clock = DateFormat.jm(Localizations.localeOf(context).languageCode);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isNext ? scheme.primaryContainer : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: isNext
            ? Border.all(color: scheme.primary.withValues(alpha: 0.4))
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isNext
                  ? scheme.primary.withValues(alpha: 0.15)
                  : scheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              timingIcon(timing),
              size: 20,
              color: isNext ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              timingName(l10n, timing),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${l10n.targetAdhan} ${clock.format(timing.adhanTime)}',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '${l10n.targetIqama} ${clock.format(timing.iqamaTime)}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
