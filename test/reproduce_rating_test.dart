import 'package:flutter_test/flutter_test.dart';
import 'package:carhartt_shop/models/product.dart';

void main() {
  group('Reproduce rating null error', () {
    test('API JSON with rating double should parse', () {
      final json = {
        "id": 1,
        "image": "https://example.com/a.jpg",
        "name": "K87 Pocket T-Shirt",
        "category": "T-Shirt",
        "rating": 4.8,
        "price": 299000,
        "description": "desc",
        "sizes": ["S", "M", "L", "XL"]
      };
      final p = Product.fromJson(json);
      print('rating=${p.rating} price=${p.price}');
      expect(p.rating, 4.8);
      expect(p.rating.toStringAsFixed(1), '4.8');
    });

    test('API JSON missing rating should fallback not crash', () {
      final json = {
        "id": 2,
        "image": "https://example.com/a.jpg",
        "name": "Test",
        "category": "T-Shirt",
        "price": 299000,
        "description": "desc",
        "sizes": ["S", "M", "L", "XL"]
        // no rating
      };
      final p = Product.fromJson(json);
      print('missing rating fallback=${p.rating}');
      expect(p.rating, 4.8);
      expect(() => p.rating.toStringAsFixed(1), returnsNormally);
    });

    test('API JSON rating as int', () {
      final json = {
        "id": 3,
        "image": "https://example.com/a.jpg",
        "name": "Test",
        "category": "Hoodie",
        "rating": 4,
        "price": 699000,
        "description": "desc",
        "sizes": ["S", "M", "L", "XL"]
      };
      final p = Product.fromJson(json);
      print('int rating=${p.rating}');
      expect(p.rating, 4.0);
    });

    test('API JSON rating as null explicit', () {
      final json = {
        "id": 4,
        "image": "https://example.com/a.jpg",
        "name": "Test",
        "category": "Jacket",
        "rating": null,
        "price": 899000,
        "description": "desc",
        "sizes": ["S", "M", "L", "XL"]
      };
      final p = Product.fromJson(json);
      print('null rating fallback=${p.rating}');
      expect(p.rating, 4.8);
    });

    test('FakeStore rating as map', () {
      final json = {
        "id": 1,
        "title": "Fjallraven Backpack",
        "price": 109.95,
        "description": "Your perfect pack",
        "category": "men's clothing",
        "image": "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg",
        "rating": {"rate": 3.9, "count": 120}
      };
      final p = Product.fromJson(json);
      print('fakestore rating map fallback=${p.rating}');
      // sekarang di-extract rate 3.9 dengan aman, tidak throw
      expect(p.rating, 3.9);
      expect(() => p.rating.toStringAsFixed(1), returnsNormally);
    });

    test('Wrapper parsing', () {
      final wrapper = {
        "success": true,
        "data": [
          {
            "id": 1,
            "image": "https://example.com/a.jpg",
            "name": "K87",
            "category": "T-Shirt",
            "rating": 4.8,
            "price": 299000,
            "description": "desc",
            "sizes": ["S", "M", "L", "XL"]
          }
        ]
      };
      final data = wrapper['data'] as List;
      final p = Product.fromJson(Map<String, dynamic>.from(data[0] as Map));
      print('wrapper parse rating=${p.rating}');
      expect(p.rating, 4.8);
    });
  });
}
