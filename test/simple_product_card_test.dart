import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carhartt_shop/widgets/product_card.dart';
import 'package:carhartt_shop/models/product.dart';

void main() {
  testWidgets('ProductCard with API product no network', (tester) async {
    final product = Product(
      id: 1,
      name: 'K87 Pocket T-Shirt',
      category: 'T-Shirt',
      price: 299000,
      image: '', // empty to avoid network
      description: 'desc',
      rating: 4.8,
      sizes: ["S", "M", "L", "XL"],
    );
    print('product rating ${product.rating}');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(width: 200, height: 300, child: ProductCard(product: product, onTap: () {})),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('K87 Pocket T-Shirt'), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);
    print('simple card ok');
  });

  testWidgets('ProductCard with null rating json', (tester) async {
    final json = {
      "id": 1,
      "image": "",
      "name": "K87",
      "category": "T-Shirt",
      "rating": null,
      "price": 299000,
      "description": "desc",
      "sizes": ["S", "M", "L", "XL"]
    };
    final product = Product.fromJson(json);
    print('fromJson null rating => ${product.rating}');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(width: 200, height: 300, child: ProductCard(product: product)),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    print('null rating card ok, rating=${product.rating}');
  });

  testWidgets('ProductCard with missing rating', (tester) async {
    final json = {
      "id": 1,
      "image": "",
      "name": "K87",
      "category": "T-Shirt",
      "price": 299000,
      "description": "desc",
      "sizes": ["S", "M", "L", "XL"]
    };
    final product = Product.fromJson(json);
    print('missing rating => ${product.rating}');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SizedBox(width: 200, height: 300, child: ProductCard(product: product))),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProductCard with FakeStore map rating', (tester) async {
    final json = {
      "id": 1,
      "title": "Backpack",
      "price": 109.95,
      "description": "desc",
      "category": "men's clothing",
      "image": "",
      "rating": {"rate": 3.9, "count": 120}
    };
    final product = Product.fromJson(json);
    print('fakestore map rating => ${product.rating}');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SizedBox(width: 200, height: 300, child: ProductCard(product: product))),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
