import '../../features/discover/domain/entities/store_item.dart';

List<StoreItem> demoStoresAround(double anchorLat, double anchorLng) {
  // Dense list of 30 markers to make the map look professional and "crowded" like the screenshots.
  const offsets = <(double dLat, double dLng, String distance)>[
    (0.0012, 0.0012, '120 m'), (-0.0008, 0.0018, '90 m'), (0.0005, -0.0015, '60 m'),
    (-0.0015, -0.0008, '180 m'), (0.0020, -0.0010, '220 m'), (-0.0022, 0.0015, '250 m'),
    (0.0008, 0.0025, '140 m'), (-0.0030, -0.0005, '310 m'), (0.0025, 0.0020, '280 m'),
    (-0.0005, -0.0025, '110 m'), (0.0015, -0.0030, '240 m'), (-0.0018, 0.0035, '290 m'),
    (0.0035, -0.0020, '400 m'), (-0.0025, -0.0035, '450 m'), (0.0040, 0.0005, '500 m'),
    (0.0010, 0.0045, '380 m'), (-0.0045, 0.0022, '650 m'), (0.0032, -0.0040, '720 m'),
    (0.0002, 0.0005, '20 m'), (-0.0004, -0.0004, '35 m'), (0.0007, -0.0008, '55 m'),
    (-0.0010, 0.0002, '85 m'), (0.0018, 0.0018, '190 m'), (-0.0025, -0.0012, '230 m'),
    (0.0038, 0.0038, '550 m'), (-0.0012, -0.0025, '170 m'), (0.0022, -0.0015, '210 m'),
    (0.0011, -0.0005, '115 m'), (-0.0006, 0.0011, '80 m'), (0.0028, 0.0028, '380 m'),
  ];

  final List<String> names = [
    'B Bagel Bakery', 'PizzaExpress', 'Caffè Nero', 'Starbucks', 
    'Gail\'s Bakery', 'Pret A Manger', 'Costa Coffee', 'Krispy Kreme', 
    'Greggs', 'Sushi Shop', 'Joe & The Juice', 'Ole & Steen', 
    'Le Pain Quotidien', 'Wasabi', 'Itsu', 'M&S Food', 'Waitrose',
    'Whole Foods', 'Lina Stores', 'Fabrique', 'Elan Cafe', 'Paul', 
    'Leon', 'Tesco Express', 'Sainsbury\'s Local'
  ];

  // Verified working images to avoid 404s
  final List<String> images = [
    'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&q=80',
    'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800&q=80',
    'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800&q=80',
    'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800&q=80',
    'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=800&q=80',
  ];

  final categoriesPool = ['Meals', 'Bread & pastries', 'Groceries', 'Flowers & plants'];

  return List.generate(offsets.length, (i) {
    final name = names[i % names.length];
    final catIndex = i % categoriesPool.length;
    return StoreItem(
      id: 'store_${i + 1}',
      name: name,
      description: 'Surprise Bag',
      imageUrl: images[i % images.length],
      logoUrl: 'https://ui-avatars.com/api/?name=${name.replaceAll(' ', '+')}&background=006A4E&color=fff',
      rating: 4.0 + (i % 10) / 10,
      pickupTime: 'Today 18:00 - 20:00',
      distance: offsets[i].$3,
      originalPrice: 12.00,
      discountedPrice: 4.00 + (i % 3),
      latitude: anchorLat + offsets[i].$1,
      longitude: anchorLng + offsets[i].$2,
      isPopular: i % 5 == 0,
      itemsLeft: i % 7 == 0 ? 2 : 0,
      categories: ['All', categoriesPool[catIndex]],
    );
  });
}
