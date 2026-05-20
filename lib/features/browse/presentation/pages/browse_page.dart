import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/config/app_maps_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/location_rationale_dialog.dart';
import '../../../../core/utils/maps_script_loader.dart';
import '../../../../core/widgets/nearby_cafes_map.dart';
import '../../../discover/presentation/widgets/store_card.dart';
import '../bloc/browse_bloc.dart';

class BrowsePage extends StatelessWidget {
  const BrowsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BrowseBloc(),
      child: const BrowseView(),
    );
  }
}

class BrowseView extends StatefulWidget {
  const BrowseView({super.key});

  @override
  State<BrowseView> createState() => _BrowseViewState();
}

class _BrowseViewState extends State<BrowseView> {
  GoogleMapController? _mapController;
  Future<void>? _webMapsScriptFuture;

  void _safeAnimateToUser(BrowseState state) {
    if (!mounted || !state.isMapMode || state.userLocation == null) return;
    final c = _mapController;
    if (c == null) return;
    try {
      c.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(state.userLocation!.latitude, state.userLocation!.longitude),
          15,
        ),
      );
    } catch (_) {
      _mapController = null;
    }
  }

  Future<void> _ensureWebMapsReady() async {
    if (!kIsWeb || !AppMapsConfig.hasWebApiKey) return;
    _webMapsScriptFuture ??= ensureGoogleMapsScriptLoaded(AppMapsConfig.webApiKey);
    await _webMapsScriptFuture;
  }

  Future<void> _switchToMapMode(BuildContext context) async {
    final ok = await showLocationPermissionRationale(context);
    if (!context.mounted || !ok) return;
    await _ensureWebMapsReady();
    if (!context.mounted) return;
    context.read<BrowseBloc>().add(const ToggleViewMode(true));
    context.read<BrowseBloc>().add(const RequestLocationPermission());
  }

  @override
  void dispose() {
    _mapController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildIconButton(Icons.location_on_outlined, () async {
              final ok = await showLocationPermissionRationale(context);
              if (!context.mounted || !ok) return;
              await _ensureWebMapsReady();
              if (!context.mounted) return;
              context.read<BrowseBloc>().add(const RequestLocationPermission());
            }),
            const SizedBox(width: 8),
            _buildIconButton(Icons.tune, () {}),
          ],
        ),
      ),
      body: BlocConsumer<BrowseBloc, BrowseState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
          if (state.userLocation != null && state.isMapMode && _mapController != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              final current = context.read<BrowseBloc>().state;
              _safeAnimateToUser(current);
            });
          }
        },
        builder: (context, state) {
          if (!state.isMapMode) {
            _mapController = null;
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildToggleOption(
                        context,
                        label: 'List',
                        isSelected: !state.isMapMode,
                        onTap: () => context.read<BrowseBloc>().add(const ToggleViewMode(false)),
                      ),
                      _buildToggleOption(
                        context,
                        label: 'Map',
                        isSelected: state.isMapMode,
                        onTap: () {
                          if (state.isMapMode) return;
                          _switchToMapMode(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: state.isMapMode ? _buildMapView(context, state) : _buildListView(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListView(BrowseState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.stores.length,
      itemBuilder: (context, index) {
        return StoreCard(item: state.stores[index], isHorizontal: false);
      },
    );
  }

  Widget _buildMapView(BuildContext context, BrowseState state) {
    if (kIsWeb && !AppMapsConfig.hasWebApiKey) {
      return buildWebMapsKeyMissingPlaceholder();
    }

    if (kIsWeb && AppMapsConfig.hasWebApiKey) {
      return FutureBuilder<void>(
        future: _webMapsScriptFuture ??= ensureGoogleMapsScriptLoaded(AppMapsConfig.webApiKey),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load Google Maps: ${snapshot.error}'),
              ),
            );
          }
          return _mapStack(context, state);
        },
      );
    }

    return _mapStack(context, state);
  }

  Widget _mapStack(BuildContext context, BrowseState state) {
    return Stack(
      children: [
        NearbyCafesMap(
          key: const ValueKey('browse_nearby_map'),
          userLocation: state.userLocation,
          stores: state.stores,
          onControllerReady: (c) {
            if (!context.read<BrowseBloc>().state.isMapMode) return;
            _mapController = c;
          },
        ),
        if (state.isLoading)
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: () async {
              if (state.userLocation != null) {
                try {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(state.userLocation!.latitude, state.userLocation!.longitude),
                      16,
                    ),
                  );
                } catch (_) {
                  _mapController = null;
                }
              } else {
                final ok = await showLocationPermissionRationale(context);
                if (!context.mounted || !ok) return;
                await _ensureWebMapsReady();
                if (!context.mounted) return;
                context.read<BrowseBloc>().add(const RequestLocationPermission());
              }
            },
            child: const Icon(Icons.my_location, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }

  Widget _buildToggleOption(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
