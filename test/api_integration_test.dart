import 'package:flutter_test/flutter_test.dart';
import 'package:carhartt_shop/services/api_service.dart';
import 'package:carhartt_shop/models/product.dart';

void main() {
  test('ApiService fetch Carhartt', () async {
    final api = ApiService.instance;
    try {
      final products = await api.fetchProductsFromCarhartt();
      print('fetched ${products.length}');
      for (final p in products) {
        print('id=${p.id} name=${p.name} rating=${p.rating} (${p.rating.runtimeType}) price=${p.price} sizes=${p.sizes}');
        // This line would throw if rating is null and we call toStringAsFixed
        final r = p.rating.toStringAsFixed(1);
        expect(r, isNotEmpty);
      }
      expect(products.length, 20);
      // Check filter
      final filtered = ApiService.filter(source: products, category: 'T-Shirt');
      print('T-Shirt filtered ${filtered.length}');
      expect(filtered.length, 5);
    } catch (e, st) {
      print('error $e');
      print(st);
      rethrow;
    }
  });

  test('ApiService fetchProducts wrapper', () async {
    final products = await ApiService.instance.fetchProducts();
    print('fetchProducts count ${products.length}');
    for (final p in products) {
      print('${p.id} ${p.rating}');
      expect(p.rating, isA<double>());
    }
  });

  test('ProductCard rating toStringAsFixed does not throw for all', () async {
    final products = await ApiService.instance.fetchProductsFromCarhartt();
    for (final p in products) {
      expect(() => p.rating.toStringAsFixed(1), returnsNormally, reason: 'id ${p.id} rating ${p.rating}');
    }
  });
}
