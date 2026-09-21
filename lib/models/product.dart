class Product {
  final int id;
  final String name;
  final String category;
  final int price; // dalam Rupiah
  final String image; // network URL
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    required this.description,
  });

  /// Format: 599000 -> "Rp 599.000"
  String get priceText => _formatRp(price);

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
    // Mendukung FakeStore API (https://fakestoreapi.com/products)
    // dan format lokal.
    final id = (json['id'] is int)
        ? json['id'] as int
        : int.tryParse(json['id']?.toString() ?? '0') ?? 0;
    final title = json['name']?.toString() ?? json['title']?.toString() ?? 'Produk';
    final category =
        json['category']?.toString() ?? 'Accessories';
    final image = json['image']?.toString() ?? '';
    final description = json['description']?.toString() ??
        '$title — original Carhartt workwear. Tahan lama untuk kerja harian.';
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
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'price': price,
        'image': image,
        'description': description,
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
