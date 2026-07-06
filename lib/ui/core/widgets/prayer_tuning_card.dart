import 'package:flutter/material.dart';
import 'package:salat_app/l10n/app_localizations.dart';

import '../../../domain/models/arrival_target.dart';
import '../../../domain/models/prayer.dart';
import '../prayer_icons.dart';
import '../prayer_names.dart';
import 'stepper_row.dart';

/// One prayer's tuning: iqama offset, optional bathroom minutes, and the
/// adhan/iqama arrival target. Shared by onboarding and Settings.
class PrayerTuningCard extends StatelessWidget {
  const PrayerTuningCard({
    super.key,
    required this.prayer,
    required this.iqamaOffset,
    required this.target,
    required this.onOffsetChanged,
    required this.onTargetChanged,
    this.bathroomMinutes,
    this.onBathroomMinutesChanged,
  });

  final Prayer prayer;
  final int iqamaOffset;
  final ArrivalTarget target;
  final ValueChanged<int> onOffsetChanged;
  final ValueChanged<ArrivalTarget> onTargetChanged;

  /// When non-null, a bathroom-minutes stepper is shown.
  final int? bathroomMinutes;
  final ValueChanged<int>? onBathroomMinutesChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Icon(prayerIcon(prayer),
                    size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(prayerName(l10n, prayer),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                StepperRow(
                  value: iqamaOffset,
                  unit: l10n.minutesShort,
                  onChanged: onOffsetChanged,
                ),
              ],
            ),
            if (bathroomMinutes != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(l10n.bathroomMinutesLabel,
                        style: theme.textTheme.bodyMedium),
                  ),
                  StepperRow(
                    value: bathroomMinutes!,
                    unit: l10n.minutesShort,
                    onChanged: onBathroomMinutesChanged ?? (_) {},
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.arriveBy, style: theme.textTheme.bodyMedium),
                SegmentedButton<ArrivalTarget>(
                  segments: [
                    ButtonSegment(
                      value: ArrivalTarget.adhan,
                      label: Text(l10n.targetAdhan),
                    ),
                    ButtonSegment(
                      value: ArrivalTarget.iqama,
                      label: Text(l10n.targetIqama),
                    ),
                  ],
                  selected: {target},
                  onSelectionChanged: (selection) =>
                      onTargetChanged(selection.first),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
