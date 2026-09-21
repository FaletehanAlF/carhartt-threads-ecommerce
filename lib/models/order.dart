import 'cart_item.dart';
import 'product.dart';

/// Status pesanan setelah checkout selesai.
/// Sesuai permintaan: hanya "Berhasil" (tidak lagi "Diproses").
const String orderStatusSuccess = 'Berhasil';

/// Status lama dipertahankan untuk kompatibilitas, tapi tidak dipakai lagi.
/// Semua pesanan baru otomatis berstatus [orderStatusSuccess].
const String orderStatusProcessing = orderStatusSuccess;

/// Daftar metode pembayaran yang didukung di Checkout.
const List<String> availablePaymentMethods = ['DANA', 'GOPAY', 'OVO', 'CASH'];

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
  final String paymentMethod;

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
    this.status = orderStatusSuccess,
    this.paymentMethod = 'CASH',
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

  /// Alamat lengkap untuk ditampilkan di detail pesanan.
  String get fullAddressText => '$address, $city $zip';

  /// Buat id unik lokal: ORD-<6 digit terakhir epoch>.
  static String newId() {
    final epoch = DateTime.now().millisecondsSinceEpoch.toString();
    final tail = epoch.length > 6
        ? epoch.substring(epoch.length - 6)
        : epoch.padLeft(6, '0');
    return 'ORD-$tail';
  }
}
