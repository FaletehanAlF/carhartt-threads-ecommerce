import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carhartt_shop/widgets/product_card.dart';
import 'package:carhartt_shop/models/product.dart';
import 'package:carhartt_shop/services/api_service.dart';

void main() {
  testWidgets('ProductCard builds without error for API product', (tester) async {
    final products = await ApiService.instance.fetchProductsFromCarhartt();
    final product = products.first;
    print('testing product id=${product.id} rating=${product.rating} price=${product.price} image=${product.image}');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 300,
            child: ProductCard(product: product, onTap: () {}),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Check for error widget
    final error = tester.takeException();
    if (error != null) {
      print('Widget error: $error');
    }
    expect(error, isNull);

    // Check rating text exists
    expect(find.text(product.rating.toStringAsFixed(1)), findsOneWidget);
    expect(find.text(product.priceText), findsOneWidget);
    print('ProductCard rendered OK');
  });

  testWidgets('ProductCard with fake missing rating should not crash', (tester) async {
    // Simulate JSON missing rating (like FakeStore)
    final json = {
      "id": 99,
      "title": "Test Fake",
      "price": 100,
      "description": "desc",
      "category": "men's clothing",
      "image": "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg",
      // no rating, no sizes
    };
    final product = Product.fromJson(json);
    print('fake product rating=${product.rating} sizes=${product.sizes}');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 300,
            child: ProductCard(product: product, onTap: () {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final error = tester.takeException();
    print('fake product widget error: $error');
    expect(error, isNull);
    expect(find.text(product.rating.toStringAsFixed(1)), findsOneWidget);
  });
}
