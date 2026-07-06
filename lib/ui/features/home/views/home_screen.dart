import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:salat_app/l10n/app_localizations.dart';

import '../../../../data/repositories/settings_repository.dart';
import '../../../../data/services/notification_service.dart';
import '../../../../domain/models/prayer_timing.dart';
import '../../../../domain/use_cases/next_prayer_resolver.dart';
import '../../../core/app_theme.dart';
import '../../../core/prayer_icons.dart';
import '../../../core/prayer_names.dart';
import '../../settings/views/settings_screen.dart';
import '../view_models/home_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.notificationService});

  /// Injectable so the app can pass the instance initialized in main().
  final NotificationService? notificationService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(
      repository: SettingsRepository(),
      notifications: widget.notificationService ?? NotificationService.instance,
    )..load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    _viewModel.notificationTexts = NotificationTexts(
      title: (prayer) => l10n.notifTitle(prayerName(l10n, prayer)),
      body: (prayer, mosqueName) =>
          l10n.notifBody(mosqueName, prayerName(l10n, prayer)),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _editTravelTime() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(
        text: '${_viewModel.settings.travelMinutes}');
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
      await _viewModel.updateTravelMinutes(minutes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              await _viewModel.refresh();
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final status = _viewModel.status;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DateHeader(
                mosqueName: _viewModel.mosque?.name,
                travelMinutes: _viewModel.settings.travelMinutes,
                onEditTravel: _editTravelTime,
              ),
              const SizedBox(height: 16),
              if (status != null) _NextPrayerCard(status: status),
              const SizedBox(height: 24),
              Text(l10n.todaysPrayers,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final timing in _viewModel.today)
                _PrayerRow(
                  timing: timing,
                  isNext: status?.timing.prayer == timing.prayer &&
                      status?.timing.adhanTime == timing.adhanTime,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({
    required this.mosqueName,
    required this.travelMinutes,
    required this.onEditTravel,
  });

  final String? mosqueName;
  final int travelMinutes;
  final VoidCallback onEditTravel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    HijriCalendar.language = locale == 'ar' ? 'ar' : 'en';
    final hijri = HijriCalendar.fromDate(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hijri.toFormat('dd MMMM yyyy'),
          style: theme.textTheme.titleLarge,
        ),
        Text(
          DateFormat.yMMMMEEEEd(locale).format(now),
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        if (mosqueName != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.mosque,
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(mosqueName!, style: theme.textTheme.bodyLarge),
                ),
                ActionChip(
                  avatar: const Icon(Icons.directions_walk, size: 18),
                  label: Text('$travelMinutes ${l10n.minutesShort}'),
                  onPressed: onEditTravel,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _NextPrayerCard extends StatelessWidget {
  const _NextPrayerCard({required this.status});

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
    const onHero = Colors.white;
    final onHeroFaded = Colors.white.withValues(alpha: 0.7);

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient(theme.colorScheme),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.seed.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(prayerIcon(status.timing.prayer),
                  color: onHeroFaded, size: 22),
              const SizedBox(width: 8),
              Text(
                prayerName(l10n, status.timing.prayer),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: onHero,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
              fontSize: 64,
              height: 1.1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            clock.format(status.timing.leaveTime),
            style: theme.textTheme.bodyMedium?.copyWith(color: onHeroFaded),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
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
              prayerIcon(timing.prayer),
              size: 20,
              color: isNext ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              prayerName(l10n, timing.prayer),
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
