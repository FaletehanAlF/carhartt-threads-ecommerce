class Product {
  final int id;
  final String name;
  final String category;
  final int price; // dalam Rupiah
  final String image; // network URL
  final String description;
  final double rating; // 1.0 - 5.0
  final List<String> sizes; // ["S","M","L","XL"]

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    required this.description,
    this.rating = 4.8,
    this.sizes = const ["S", "M", "L", "XL"],
  });

  /// Format: 599000 -> "Rp 599.000"
  String get priceText => _formatRp(price);

  /// Helper statis agar CartItem / CartPage bisa format subtotal/total
  /// tanpa harus membuat instance Product dummy.
  static String priceTextStatic(int value) => _formatRp(value);

  static String _formatRp(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write('.');
        count = 0;
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    // Mendukung API Carhartt Shop (/api/products) + FakeStore + format lokal.
    final id = (json['id'] is int)
        ? json['id'] as int
        : int.tryParse(json['id']?.toString() ?? '0') ?? 0;
    final title = json['name']?.toString() ?? json['title']?.toString() ?? 'Produk';
    final category =
        json['category']?.toString() ?? 'Accessories';
    final image = json['image']?.toString() ?? '';
    final description = json['description']?.toString() ??
        '$title — original Carhartt workwear. Tahan lama untuk kerja harian.';

    // Rating: 1.0 - 5.0
    double ratingValue = 4.8;
    if (json['rating'] is num) {
      ratingValue = (json['rating'] as num).toDouble().clamp(1.0, 5.0);
    } else if (json['rating'] != null) {
      ratingValue = double.tryParse(json['rating'].toString())?.clamp(1.0, 5.0) ?? 4.8;
    }

    // Sizes: ["S","M","L","XL"]
    List<String> sizesValue = const ["S", "M", "L", "XL"];
    if (json['sizes'] is List) {
      final parsed = (json['sizes'] as List).map((e) => e.toString().toUpperCase()).where((e) => e.isNotEmpty).toList();
      if (parsed.isNotEmpty) sizesValue = parsed;
    }

    int priceValue = 0;
    final rawPrice = json['price'];
    if (rawPrice is num) {
      // Harga FakeStore dalam USD -> konversi kasar ke IDR untuk demo.
      // Kalau datanya sudah IDR (int besar), pakai langsung.
      if (rawPrice < 10000) {
        priceValue = (rawPrice * 15500).round();
      } else {
        priceValue = rawPrice.toInt();
      }
    } else {
      final digits =
          json['price']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '';
      priceValue = int.tryParse(digits) ?? 0;
    }
    return Product(
      id: id,
      name: title,
      category: _normalizeCategory(category),
      price: priceValue,
      image: image,
      description: description,
      rating: ratingValue,
      sizes: sizesValue,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'price': price,
        'image': image,
        'description': description,
        'rating': rating,
        'sizes': sizes,
      };

  static String _normalizeCategory(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('t-shirt') ||
        lower.contains('tshirt') ||
        lower.contains("men's clothing") ||
        lower.contains('shirt')) {
      // Bedakan kasar: kalau ada kata jacket/hoodie/pant, prioritaskan itu.
      if (lower.contains('jacket')) return 'Jacket';
      if (lower.contains('hoodie') || lower.contains('sweat')) return 'Hoodie';
      if (lower.contains('pant') || lower.contains('jean') || lower.contains('short')) {
        return 'Pants';
      }
      if (lower.contains('bag') || lower.contains('backpack')) return 'Bag';
      if (lower.contains('cap') || lower.contains('hat') || lower.contains('jewel')) {
        return 'Accessories';
      }
      return 'T-Shirt';
    }
    if (lower.contains('hoodie') || lower.contains('sweat')) return 'Hoodie';
    if (lower.contains('jacket') || lower.contains('coat') || lower.contains('vest') || lower.contains('overshirt')) {
      return 'Jacket';
    }
    if (lower.contains('pant') ||
        lower.contains('jean') ||
        lower.contains('short') ||
        lower.contains('cargo')) {
      return 'Pants';
    }
    if (lower.contains('bag') || lower.contains('backpack')) return 'Bag';
    return 'Accessories';
  }
}
