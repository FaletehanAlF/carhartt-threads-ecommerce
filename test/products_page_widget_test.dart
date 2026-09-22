import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carhartt_shop/pages/productsPage.dart';
import 'package:carhartt_shop/services/product_repository.dart';
import 'package:carhartt_shop/services/api_service.dart';

void main() {
  testWidgets('ProductsPage displays products without red error', (tester) async {
    // Preload repository with API data
    final products = await ApiService.instance.fetchProductsFromCarhartt();
    print('Loaded ${products.length} products for test');
    for (final p in products) {
      print('product ${p.id} rating=${p.rating} type=${p.rating.runtimeType}');
    }

    // Inject into repository
    ProductRepository.instance.productsNotifier.value = products;
    ProductRepository.instance.sourceNotifier.value = 'Test';

    await tester.pumpWidget(
      const MaterialApp(
        home: ProductsPage(),
      ),
    );

    // Pump a frame
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Look for error widgets
    final errorWidgets = find.byType(ErrorWidget);
    print('Error widgets found: ${tester.widgetList(errorWidgets).length}');
    if (tester.widgetList(errorWidgets).isNotEmpty) {
      final firstError = tester.widgetList<ErrorWidget>(errorWidgets).first;
      print('First error message: ${firstError.message}');
    }

    // Should have no error widgets
    expect(find.byType(ErrorWidget), findsNothing, reason: 'ProductCard should not be red error');

    // Should find product names
    expect(find.text('K87 Pocket T-Shirt'), findsOneWidget);
    expect(find.textContaining('Products'), findsOneWidget);
  });
}
