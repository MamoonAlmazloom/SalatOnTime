import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:salat_app/l10n/app_localizations.dart';

import '../../../../domain/models/mosque.dart';

/// Full-screen map to (re)pick the mosque. Pops with the new [Mosque].
class MosquePickerScreen extends StatefulWidget {
  const MosquePickerScreen({super.key, this.initial});

  final Mosque? initial;

  @override
  State<MosquePickerScreen> createState() => _MosquePickerScreenState();
}

class _MosquePickerScreenState extends State<MosquePickerScreen> {
  late final TextEditingController _nameController;
  late double _latitude;
  late double _longitude;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initial?.name ?? '');
    _latitude = widget.initial?.latitude ?? 24.7136;
    _longitude = widget.initial?.longitude ?? 46.6753;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    Navigator.of(context).pop(Mosque(
      name: name.isEmpty ? l10n.mosqueNameDefault : name,
      latitude: _latitude,
      longitude: _longitude,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.changeMosque)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.mosqueNameLabel,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.mosque),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(_latitude, _longitude),
                    initialZoom: 16,
                    onPositionChanged: (camera, hasGesture) {
                      _latitude = camera.center.latitude;
                      _longitude = camera.center.longitude;
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
                IgnorePointer(
                  child: Transform.translate(
                    offset: const Offset(0, -24),
                    child: Icon(Icons.location_pin,
                        size: 48, color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: Text(l10n.save),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
