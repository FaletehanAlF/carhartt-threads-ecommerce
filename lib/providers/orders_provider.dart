import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item.dart';
import '../models/order.dart';

/// Sumber state utama Riwayat Pesanan (Riverpod).
///
/// Pola sama seperti Cart:
/// - baca state: `ref.watch(ordersProvider)`
/// - ubah state: `ref.read(ordersProvider.notifier).placeOrder(...)`
///
/// Penyimpanan masih in-memory (tahap pertama). Strukturnya sudah
/// menyerupai payload order backend (items + alamat + total) sehingga
/// nanti tinggal diganti dengan pemanggilan API.
final ordersProvider =
    NotifierProvider<OrdersNotifier, List<Order>>(OrdersNotifier.new);

/// Jumlah pesanan (untuk badge/menu).
final ordersCountProvider = Provider<int>((ref) {
  return ref.watch(ordersProvider).length;
});

class OrdersNotifier extends Notifier<List<Order>> {
  @override
  List<Order> build() => const [];

  /// Buat pesanan baru dari snapshot [items] Cart + alamat.
  /// Return [Order] yang dibuat (untuk snackbar/navigasi).
  Order placeOrder({
    required List<CartItem> items,
    required String receiverName,
    required String phone,
    required String address,
    required String city,
    required String zip,
    required int subtotal,
    required int shipping,
    required int total,
  }) {
    final order = Order(
      id: Order.newId(),
      items: items,
      receiverName: receiverName.trim(),
      phone: phone.trim(),
      address: address.trim(),
      city: city.trim(),
      zip: zip.trim(),
      subtotal: subtotal,
      shipping: shipping,
      total: total,
      createdAt: DateTime.now(),
    );
    // Pesanan terbaru di paling atas.
    state = [order, ...state];
    return order;
  }

  /// Hapus seluruh riwayat (dipakai dari Settings).
  void clear() {
    state = const [];
  }
}
