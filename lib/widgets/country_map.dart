import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/config/app_config.dart';
import '../core/theme/app_colors.dart';

/// OpenStreetMap view centred on a location with a marker.
class CountryMap extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double zoom;
  final bool interactive;

  const CountryMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 4,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);

    return FlutterMap(
      options: MapOptions(
        initialCenter: point,
        initialZoom: zoom,
        interactionOptions: InteractionOptions(
          flags: interactive
              ? InteractiveFlag.all & ~InteractiveFlag.rotate
              : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: AppConfig.mapTileUrl,
          userAgentPackageName: AppConfig.mapUserAgent,
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: point,
              width: 48,
              height: 48,
              alignment: Alignment.topCenter,
              child: const Icon(Icons.location_on, size: 48, color: AppColors.favorite),
            ),
          ],
        ),
        const RichAttributionWidget(
          attributions: [TextSourceAttribution('OpenStreetMap contributors')],
        ),
      ],
    );
  }
}
