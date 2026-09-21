import 'cart_item.dart';
import 'product.dart';

/// Status awal pesanan (tahap pertama, lokal saja).
///
/// Nanti tinggal diganti dari response backend / payment gateway
/// (mis. menunggu pembayaran, dibayar, dikirim, selesai, dibatalkan).
const String orderStatusProcessing = 'Diproses';

/// Satu pesanan — snapshot dari Cart saat user menekan Bayar Sekarang.
///
/// [items] disalin (unmodifiable) agar tidak ikut berubah saat Cart
/// dikosongkan/diubah setelah checkout.
class Order {
  final String id;
  final List<CartItem> items;
  final String receiverName;
  final String phone;
  final String address;
  final String city;
  final String zip;
  final int subtotal;
  final int shipping;
  final int total;
  final DateTime createdAt;
  final String status;

  Order({
    required this.id,
    required List<CartItem> items,
    required this.receiverName,
    required this.phone,
    required this.address,
    required this.city,
    required this.zip,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.createdAt,
    this.status = orderStatusProcessing,
  }) : items = List<CartItem>.unmodifiable(
          items.map((e) => e.copyWith()),
        );

  int get totalQty =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);

  String get totalText => Product.priceTextStatic(total);

  /// "12/09/2026 14:05" — format manual tanpa package tambahan.
  String get dateText {
    final d = createdAt;
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} '
        '${two(d.hour)}:${two(d.minute)}';
  }

  /// Buat id unik lokal: ORD-<6 digit terakhir epoch>.
  static String newId() {
    final epoch = DateTime.now().millisecondsSinceEpoch.toString();
    final tail = epoch.length > 6
        ? epoch.substring(epoch.length - 6)
        : epoch.padLeft(6, '0');
    return 'ORD-$tail';
  }
}
