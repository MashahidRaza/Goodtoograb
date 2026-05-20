import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../features/discover/domain/entities/store_item.dart';
import '../theme/app_colors.dart';
import '../utils/map_cafe_marker_bitmap.dart';

/// Google Map with live blue dot on mobile ([myLocationEnabled]) and custom
/// café markers (image + name on bitmap). Same [StoreItem] model works when
/// you later load cafés from your API (name, logoUrl/imageUrl, lat, lng).
class NearbyCafesMap extends StatefulWidget {
  const NearbyCafesMap({
    super.key,
    required this.userLocation,
    required this.stores,
    this.onControllerReady,
    this.padding = EdgeInsets.zero,
  });

  final Position? userLocation;
  final List<StoreItem> stores;
  final void Function(GoogleMapController controller)? onControllerReady;
  final EdgeInsets padding;

  @override
  State<NearbyCafesMap> createState() => _NearbyCafesMapState();
}

class _NearbyCafesMapState extends State<NearbyCafesMap> {
  GoogleMapController? _controller;
  final Map<String, BitmapDescriptor> _cafeIcons = {};
  String _storesSignature = '';

  @override
  void didUpdateWidget(covariant NearbyCafesMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userLocation != oldWidget.userLocation && widget.userLocation != null && _controller != null) {
      _animateToUser();
    }
    if (_signature(widget.stores) != _signature(oldWidget.stores)) {
      _scheduleIconBuild();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleIconBuild());
  }

  String _signature(List<StoreItem> list) {
    return list.map((e) => '${e.id}|${e.logoUrl}|${e.name}').join('~');
  }

  void _scheduleIconBuild() {
    final sig = _signature(widget.stores);
    if (sig == _storesSignature && _cafeIcons.length == widget.stores.length) return;
    final keep = widget.stores.map((e) => e.id).toSet();
    _cafeIcons.removeWhere((k, _) => !keep.contains(k));
    _storesSignature = sig;
    _buildCafeIconsAsync();
  }

  Future<void> _buildCafeIconsAsync() async {
    final stores = List<StoreItem>.from(widget.stores);
    if (!mounted || stores.isEmpty) return;
    final dpr = MediaQuery.devicePixelRatioOf(context);

    for (final store in stores) {
      if (!mounted) return;
      try {
        final icon = await buildCafeMarkerBitmap(store, pixelRatio: dpr);
        if (!mounted) return;
        if (icon != null) {
          setState(() => _cafeIcons[store.id] = icon);
        }
      } catch (_) {
        // keep default pin for this id until retry
      }
    }
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  Future<void> _animateToUser() async {
    final p = widget.userLocation;
    if (p == null || _controller == null || !mounted) return;
    try {
      await _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(p.latitude, p.longitude), 15),
      );
    } catch (_) {
      _controller = null;
    }
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    for (final store in widget.stores) {
      final custom = _cafeIcons[store.id];
      markers.add(
        Marker(
          markerId: MarkerId(store.id),
          position: LatLng(store.latitude, store.longitude),
          icon: custom ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          anchor: const Offset(0.5, 1),
          zIndexInt: 1,
          infoWindow: InfoWindow(title: store.name, snippet: store.description),
        ),
      );
    }
    if (kIsWeb && widget.userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_user'),
          position: LatLng(widget.userLocation!.latitude, widget.userLocation!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          anchor: const Offset(0.5, 1),
          zIndexInt: 2,
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final LatLng initial = widget.userLocation != null
        ? LatLng(widget.userLocation!.latitude, widget.userLocation!.longitude)
        : const LatLng(51.5081, -0.1281);

    return GoogleMap(
      padding: widget.padding,
      initialCameraPosition: CameraPosition(target: initial, zoom: widget.userLocation != null ? 15 : 13),
      markers: _buildMarkers(),
      myLocationEnabled: !kIsWeb,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: true,
      mapToolbarEnabled: false,
      onMapCreated: (c) {
        _controller = c;
        widget.onControllerReady?.call(c);
        if (widget.userLocation != null) {
          _animateToUser();
        }
        _scheduleIconBuild();
      },
    );
  }
}

Widget buildWebMapsKeyMissingPlaceholder() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 56, color: Colors.grey.shade600),
          const SizedBox(height: 16),
          Text(
            'Google Maps on web needs an API key',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey.shade800),
          ),
          const SizedBox(height: 12),
          const Text(
            'Run the app with:\n'
            'flutter run -d chrome --dart-define=GOOGLE_MAPS_WEB_API_KEY=your_key\n\n'
            'Use a key with the Maps JavaScript API enabled.',
            textAlign: TextAlign.center,
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 12),
            Text('kIsWeb=$kIsWeb', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ],
      ),
    ),
  );
}
