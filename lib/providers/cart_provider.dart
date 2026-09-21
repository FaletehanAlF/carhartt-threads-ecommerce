import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

/// Sumber state utama Cart (Riverpod).
///
/// Pola sesuai dokumentasi:
/// - baca state: `ref.watch(cartProvider)`
/// - ubah state: `ref.read(cartProvider.notifier).addProduct(...)`
/// - badge/total: `ref.watch(cartTotalQuantityProvider)` /
///   `ref.watch(cartTotalPriceProvider)`
///
/// Menggunakan [Notifier] + [NotifierProvider] (API modern Riverpod 3,
/// pengganti StateProvider untuk state berupa list dengan banyak operasi).
/// `StateProvider` hanya cocok untuk state primitif tunggal (mis. counter),
/// sedangkan Cart butuh add/increase/decrease/remove/clear.
final cartProvider =
    NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

/// Total quantity semua item (untuk badge cart).
final cartTotalQuantityProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold<int>(0, (sum, item) => sum + item.quantity);
});

/// Total harga semua item.
final cartTotalPriceProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold<int>(0, (sum, item) => sum + item.subtotal);
});

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => const [];

  /// Tambah produk ke cart. Jika produk+size sudah ada, quantity ditambah.
  void addProduct(
    Product product, {
    int quantity = 1,
    String size = 'M',
  }) {
    if (quantity <= 0) return;
    final normalizedSize = size.isEmpty ? 'M' : size.toUpperCase();
    final key = '${product.id}|$normalizedSize';
    final index = state.indexWhere((e) => e.key == key);
    if (index >= 0) {
      final existing = state[index];
      final updated = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
      state = [
        for (var i = 0; i < state.length; i++)
          if (i == index) updated else state[i],
      ];
    } else {
      state = [
        ...state,
        CartItem(
          product: product,
          size: normalizedSize,
          quantity: quantity,
        ),
      ];
    }
  }

  /// Tambah quantity 1 untuk baris [productId] + [size].
  /// Jika [size] null, tambah ke semua baris produk tersebut.
  void increaseQuantity(int productId, {String? size}) {
    state = [
      for (final item in state)
        if (item.product.id == productId &&
            (size == null ||
                item.size.toUpperCase() == size.toUpperCase()))
          item.copyWith(quantity: item.quantity + 1)
        else
          item,
    ];
  }

  /// Kurangi quantity 1. Jika quantity menjadi 0, baris dihapus.
  void decreaseQuantity(int productId, {String? size}) {
    final next = <CartItem>[];
    for (final item in state) {
      final match = item.product.id == productId &&
          (size == null || item.size.toUpperCase() == size.toUpperCase());
      if (!match) {
        next.add(item);
      } else if (item.quantity > 1) {
        next.add(item.copyWith(quantity: item.quantity - 1));
      }
      // quantity == 1 + decrease -> baris dihapus (tidak dimasukkan).
    }
    state = next;
  }

  /// Hapus baris [productId] + [size].
  /// Jika [size] null, hapus semua baris produk tersebut.
  void removeProduct(int productId, {String? size}) {
    state = state
        .where(
          (item) =>
              !(item.product.id == productId &&
                  (size == null ||
                      item.size.toUpperCase() == size.toUpperCase())),
        )
        .toList();
  }

  /// Hapus baris persis [item.key].
  void removeItem(CartItem item) {
    state = state.where((e) => e.key != item.key).toList();
  }

  /// Kosongkan seluruh cart.
  void clear() {
    state = const [];
  }

  /// Cek apakah produk sudah ada di cart.
  /// Jika [size] diisi, cek spesifik ukuran tersebut.
  bool contains(int productId, {String? size}) {
    return state.any(
      (item) =>
          item.product.id == productId &&
          (size == null || item.size.toUpperCase() == size.toUpperCase()),
    );
  }

  /// Total quantity (bisa juga via [cartTotalQuantityProvider]).
  int get totalQuantity =>
      state.fold<int>(0, (sum, item) => sum + item.quantity);

  /// Total harga (bisa juga via [cartTotalPriceProvider]).
  int get totalPrice =>
      state.fold<int>(0, (sum, item) => sum + item.subtotal);

  /// Subtotal satu baris.
  int subtotalFor(CartItem item) => item.subtotal;

  /// Quantity produk tertentu (semua ukuran digabung jika size null).
  int quantityOf(int productId, {String? size}) {
    return state
        .where(
          (item) =>
              item.product.id == productId &&
              (size == null ||
                  item.size.toUpperCase() == size.toUpperCase()),
        )
        .fold<int>(0, (sum, item) => sum + item.quantity);
  }
}
