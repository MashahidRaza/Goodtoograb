import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/store_item.dart';
import '../../../../core/data/demo_nearby_stores.dart';

// Events
abstract class DiscoverEvent extends Equatable {
  const DiscoverEvent();
  @override
  List<Object?> get props => [];
}

class LoadDiscoverData extends DiscoverEvent {}

class ChangeCategory extends DiscoverEvent {
  final String category;
  const ChangeCategory(this.category);
  @override
  List<Object?> get props => [category];
}

class ToggleFavorite extends DiscoverEvent {
  final String storeId;
  const ToggleFavorite(this.storeId);
  @override
  List<Object?> get props => [storeId];
}

// States
class DiscoverState extends Equatable {
  final List<StoreItem> allStores;
  final Set<String> favoriteIds;
  final String selectedCategory;
  final bool isLoading;

  const DiscoverState({
    this.allStores = const [],
    this.favoriteIds = const {},
    this.selectedCategory = 'All',
    this.isLoading = false,
  });

  // Business Logic: Derived Getters for filtering
  List<StoreItem> get topPicks {
    return allStores.where((s) {
      final matchesCategory = selectedCategory == 'All' || s.categories.contains(selectedCategory);
      // Logic for top picks: high rating or marked as popular
      return matchesCategory && (s.isPopular || s.rating >= 4.4);
    }).toList();
  }

  List<StoreItem> get saveBeforeTooLate {
    return allStores.where((s) {
      final matchesCategory = selectedCategory == 'All' || s.categories.contains(selectedCategory);
      // Logic for saving: few items left or high discount
      return matchesCategory && (s.itemsLeft > 0 || s.discountedPrice < 5);
    }).toList();
  }

  List<StoreItem> get favoriteStores => allStores.where((s) => favoriteIds.contains(s.id)).toList();

  DiscoverState copyWith({
    List<StoreItem>? allStores,
    Set<String>? favoriteIds,
    String? selectedCategory,
    bool? isLoading,
  }) {
    return DiscoverState(
      allStores: allStores ?? this.allStores,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [allStores, favoriteIds, selectedCategory, isLoading];
}

class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  DiscoverBloc() : super(const DiscoverState()) {
    on<LoadDiscoverData>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 600));
      
      // Load 30+ stores from our accurate data source
      // Covent Garden default coordinates
      final stores = demoStoresAround(51.5074, -0.1278);

      emit(state.copyWith(
        allStores: stores,
        isLoading: false,
      ));
    });

    on<ChangeCategory>((event, emit) {
      emit(state.copyWith(selectedCategory: event.category));
    });

    on<ToggleFavorite>((event, emit) {
      final newFavorites = Set<String>.from(state.favoriteIds);
      if (newFavorites.contains(event.storeId)) {
        newFavorites.remove(event.storeId);
      } else {
        newFavorites.add(event.storeId);
      }
      emit(state.copyWith(favoriteIds: newFavorites));
    });
  }
}
