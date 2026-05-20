import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/data/demo_nearby_stores.dart';
import '../../../../core/utils/location_service.dart';
import '../../../discover/domain/entities/store_item.dart';

const _unset = Object();

abstract class BrowseEvent extends Equatable {
  const BrowseEvent();
  @override
  List<Object?> get props => [];
}

class ToggleViewMode extends BrowseEvent {
  const ToggleViewMode(this.isMapMode);

  final bool isMapMode;

  @override
  List<Object?> get props => [isMapMode];
}

class RequestLocationPermission extends BrowseEvent {
  const RequestLocationPermission();
}

class LoadBrowseData extends BrowseEvent {
  const LoadBrowseData();
}

class BrowseState extends Equatable {
  final bool isMapMode;
  final Position? userLocation;
  final List<StoreItem> stores;
  final String? errorMessage;
  final bool isLoading;

  const BrowseState({
    this.isMapMode = false,
    this.userLocation,
    this.stores = const [],
    this.errorMessage,
    this.isLoading = false,
  });

  BrowseState copyWith({
    bool? isMapMode,
    Object? userLocation = _unset,
    List<StoreItem>? stores,
    Object? errorMessage = _unset,
    bool? isLoading,
  }) {
    return BrowseState(
      isMapMode: isMapMode ?? this.isMapMode,
      userLocation: identical(userLocation, _unset) ? this.userLocation : userLocation as Position?,
      stores: stores ?? this.stores,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [isMapMode, userLocation, stores, errorMessage, isLoading];
}

class BrowseBloc extends Bloc<BrowseEvent, BrowseState> {
  BrowseBloc() : super(const BrowseState()) {
    on<ToggleViewMode>((event, emit) {
      emit(state.copyWith(isMapMode: event.isMapMode));
    });

    on<RequestLocationPermission>((event, emit) async {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      try {
        final position = await _locationService.getCurrentLocation();
        final stores = demoStoresAround(position.latitude, position.longitude);
        emit(
          state.copyWith(
            userLocation: position,
            stores: stores,
            isLoading: false,
            errorMessage: null,
          ),
        );
      } on LocationException catch (e) {
        emit(state.copyWith(errorMessage: e.message, isLoading: false));
      } catch (e) {
        emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
      }
    });

    on<LoadBrowseData>((event, emit) {
      if (state.stores.isEmpty) {
        emit(state.copyWith(stores: demoStoresAround(51.5081, -0.1281)));
      }
    });

    add(const LoadBrowseData());
  }

  final LocationService _locationService = LocationService();
}
