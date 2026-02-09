import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';

/// Interactive OpenStreetMap section with center pin marker.
/// Pin stays at center; dragging map updates coordinates.
class AddressMapSection extends StatelessWidget {
  /// Map controller for programmatic use.
  final MapController mapController;

  /// Current center coordinate.
  final LatLng center;

  /// Whether dark mode is active.
  final bool isDark;

  /// Callback when map is moved (new center).
  final ValueChanged<LatLng> onMapMoved;

  /// Creates the AddressMapSection widget.
  const AddressMapSection({
    super.key,
    required this.mapController,
    required this.center,
    required this.isDark,
    required this.onMapMoved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark ? null : [BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8)]),
      clipBehavior: Clip.hardEdge,
      child: Stack(children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 17,
            onPositionChanged: (pos, _) {
              if (pos.center != null) onMapMoved(pos.center!);
            }),
          children: [
            TileLayer(
              urlTemplate: isDark
                  ? 'https://{s}.basemaps.cartocdn.com/'
                    'rastertiles/dark_all/{z}/{x}/{y}@2x.png'
                  : 'https://{s}.basemaps.cartocdn.com/'
                    'rastertiles/voyager_labels_under/'
                    '{z}/{x}/{y}@2x.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              retinaMode: true,
              userAgentPackageName:
                  'com.delivery.delivery_app'),
          ]),
        const Center(child: Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: Icon(Icons.location_on, size: 40,
              color: AppColors.primary))),
        Positioned(bottom: 4, left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withOpacity(0.6)
                  : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(4)),
            child: Text('© OpenStreetMap',
                style: TextStyle(fontSize: 9,
                    color: isDark ? Colors.white60
                        : Colors.black54)))),
      ]));
  }
}
