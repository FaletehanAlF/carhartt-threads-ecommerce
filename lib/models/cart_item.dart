import 'product.dart';

/// Satu baris item di keranjang.
///
/// Dibedakan per [product.id] + [size] agar kaos ukuran M dan L
/// tercatat sebagai dua baris terpisah (sesuai pilihan Size
/// di Product Detail).
class CartItem {
  final Product product;
  final String size;
  final int quantity;

  const CartItem({
    required this.product,
    this.size = 'M',
    this.quantity = 1,
  });

  /// Subtotal baris ini: harga satuan x quantity.
  int get subtotal => product.price * quantity;

  String get subtotalText => Product.priceTextStatic(subtotal);

  CartItem copyWith({
    Product? product,
    String? size,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
    );
  }

  /// Kunci unik baris: "productId|SIZE".
  String get key => '${product.id}|${size.toUpperCase()}';
}
