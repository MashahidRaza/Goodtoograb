import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/data/demo_nearby_stores.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/location_rationale_dialog.dart';
import '../../../../core/utils/location_service.dart';
import '../../../../core/widgets/nearby_cafes_map.dart';
import '../../domain/entities/store_item.dart';

Future<void> showLocationPickerSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return const _LocationPickerBody();
    },
  );
}

class _LocationPickerBody extends StatefulWidget {
  const _LocationPickerBody();

  @override
  State<_LocationPickerBody> createState() => _LocationPickerBodyState();
}

class _LocationPickerBodyState extends State<_LocationPickerBody> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(child: _segmentLabel('Areas', 0)),
                    Expanded(child: _segmentLabel('Map', 1)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _tabIndex == 0
                  ? _HardcodedAreasList(scrollController: scrollController)
                  : const _MapPickerTab(),
            ),
          ],
        );
      },
    );
  }

  Widget _segmentLabel(String label, int index) {
    final selected = _tabIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _tabIndex = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _HardcodedAreasList extends StatelessWidget {
  const _HardcodedAreasList({required this.scrollController});

  final ScrollController scrollController;

  static const _areas = <String>[
    'Covent Garden, London',
    'Soho, London',
    'Strand / Charing Cross',
    'Southbank (placeholder)',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _areas.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.place_outlined, color: AppColors.primary),
          title: Text(_areas[index]),
          onTap: () => Navigator.of(context).pop(),
        );
      },
    );
  }
}

class _MapPickerTab extends StatefulWidget {
  const _MapPickerTab();

  @override
  State<_MapPickerTab> createState() => _MapPickerTabState();
}

class _MapPickerTabState extends State<_MapPickerTab> {
  final LocationService _location = LocationService();
  GoogleMapController? _mapController;
  Position? _position;
  List<StoreItem> _stores = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // THE FIX: Wait until the widget is fully built before showing dialogs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadLocation();
    });
  }

  Future<void> _loadLocation() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ok = await showLocationPermissionRationale(context);
      if (!ok) {
        if (mounted) setState(() { _loading = false; _error = 'Skipped location.'; });
        return;
      }
      final pos = await _location.getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _position = pos;
        _stores = demoStoresAround(pos.latitude, pos.longitude);
        _loading = false;
      });
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 15));
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && _position == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            FilledButton(onPressed: _loadLocation, child: const Text('Try again')),
          ],
        ),
      );
    }
    if (_loading && _position == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    return Stack(
      children: [
        NearbyCafesMap(
          userLocation: _position,
          stores: _stores,
          onControllerReady: (c) => _mapController = c,
        ),
        if (_loading) const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        Positioned(
          right: 16, bottom: 16,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: _loadLocation,
            child: const Icon(Icons.my_location, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
