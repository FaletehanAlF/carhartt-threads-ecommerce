import 'package:flutter/material.dart';

import '../data/products.dart' as local;
import '../models/product.dart';
import 'api_service.dart';

/// Cache produk in-memory agar Home / Products / Favorite
/// selalu melihat daftar yang sama (konsisten untuk favorit).
class ProductRepository {
  ProductRepository._();
  static final ProductRepository instance = ProductRepository._();

  final ValueNotifier<List<Product>> productsNotifier =
      ValueNotifier<List<Product>>(
    List<Product>.from(local.products),
  );

  final ValueNotifier<String> sourceNotifier =
      ValueNotifier<String>('Offline • Lokal');

  final ValueNotifier<bool> loadingNotifier = ValueNotifier<bool>(false);

  List<Product> get current => productsNotifier.value;

  Product? byId(int id) {
    try {
      return current.firstWhere((p) => p.id == id);
    } catch (_) {
      // cari juga di katalog lokal (misal favorit lama)
      try {
        return local.products.firstWhere((p) => p.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  /// Muat dari jaringan (Carhartt API → Dio → HTTP → lokal).
  /// Dipanggil sekali saat ProductsPage dibuka + saat user refresh.
  ///
  /// Dijamin tidak pernah mengisi notifier dengan tipe yang salah:
  /// setiap hasil dikopi ke `List<Product>` baru, dan semua error
  /// (termasuk di Flutter Web) jatuh ke katalog lokal.
  Future<void> refresh() async {
    if (loadingNotifier.value) return;
    loadingNotifier.value = true;
    try {
      // 1. Coba Carhartt API dulu (Dio)
      try {
        final viaCarhartt = await ApiService.instance.fetchProductsFromCarhartt();
        if (viaCarhartt.isNotEmpty) {
          productsNotifier.value = List<Product>.from(viaCarhartt);
          sourceNotifier.value = 'Online • Carhartt API';
          return;
        }
      } catch (_) {}

      // 2. Coba Dio (akan coba Carhartt + FakeStore di dalamnya)
      try {
        final viaDio = await ApiService.instance.fetchProductsWithDio();
        if (viaDio.isNotEmpty) {
          // Bedakan label jika 20 produk Carhartt
          final isCarhartt = viaDio.length == 20 && viaDio.every((p) => p.sizes.isNotEmpty && p.rating >= 4.0);
          productsNotifier.value = List<Product>.from(viaDio);
          sourceNotifier.value = isCarhartt ? 'Online • Carhartt API' : 'Online • Dio';
          return;
        }
      } catch (_) {}

      // 3. Coba HTTP
      try {
        final viaHttp = await ApiService.instance.fetchProductsWithHttp();
        if (viaHttp.isNotEmpty) {
          final isCarhartt = viaHttp.length == 20;
          productsNotifier.value = List<Product>.from(viaHttp);
          sourceNotifier.value = isCarhartt ? 'Online • Carhartt API' : 'Online • HTTP';
          return;
        }
      } catch (_) {}

      productsNotifier.value = List<Product>.from(local.products);
      sourceNotifier.value = 'Offline • Lokal';
    } catch (_) {
      try {
        productsNotifier.value = List<Product>.from(local.products);
      } catch (_) {}
      sourceNotifier.value = 'Offline • Lokal';
    } finally {
      loadingNotifier.value = false;
    }
  }
}
