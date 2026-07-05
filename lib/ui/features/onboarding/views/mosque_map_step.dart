import 'package:flutter/material.dart';
import 'package:salat_app/l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../view_models/onboarding_view_model.dart';

class MosqueMapStep extends StatelessWidget {
  const MosqueMapStep({super.key, required this.viewModel});

  final OnboardingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(l10n.mosqueStepHint,
              style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: TextField(
            decoration: InputDecoration(
              labelText: l10n.mosqueNameLabel,
              hintText: l10n.mosqueNameDefault,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.mosque),
            ),
            onChanged: viewModel.setMosqueName,
          ),
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(
                    viewModel.mapCenterLatitude,
                    viewModel.mapCenterLongitude,
                  ),
                  initialZoom: 16,
                  onPositionChanged: (camera, hasGesture) {
                    viewModel.setMosquePosition(
                      camera.center.latitude,
                      camera.center.longitude,
                    );
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.salatapp.salat_app',
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
              // Fixed center pin: the map moves underneath it. Lifted so the
              // pin's tip (not its middle) marks the selected point.
              IgnorePointer(
                child: Transform.translate(
                  offset: const Offset(0, -24),
                  child: Icon(
                    Icons.location_pin,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
