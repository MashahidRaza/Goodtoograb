import 'package:equatable/equatable.dart';

class StoreItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String logoUrl;
  final double rating;
  final String pickupTime;
  final String distance;
  final double originalPrice;
  final double discountedPrice;
  final int itemsLeft;
  final bool isPopular;
  final double latitude;
  final double longitude;
  final List<String> categories;

  const StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.logoUrl,
    required this.rating,
    required this.pickupTime,
    required this.distance,
    required this.originalPrice,
    required this.discountedPrice,
    this.itemsLeft = 0,
    this.isPopular = false,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.categories = const ['All'],
  });

  StoreItem copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? logoUrl,
    double? rating,
    String? pickupTime,
    String? distance,
    double? originalPrice,
    double? discountedPrice,
    int? itemsLeft,
    bool? isPopular,
    double? latitude,
    double? longitude,
    List<String>? categories,
  }) {
    return StoreItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      rating: rating ?? this.rating,
      pickupTime: pickupTime ?? this.pickupTime,
      distance: distance ?? this.distance,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      itemsLeft: itemsLeft ?? this.itemsLeft,
      isPopular: isPopular ?? this.isPopular,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        logoUrl,
        rating,
        pickupTime,
        distance,
        originalPrice,
        discountedPrice,
        itemsLeft,
        isPopular,
        latitude,
        longitude,
        categories,
      ];
}
