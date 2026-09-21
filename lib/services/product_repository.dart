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
      ValueNotifier<List<Product>>(List.of(local.products));

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

  /// Muat dari jaringan (dio dulu, lalu http, lalu lokal).
  /// Dipanggil sekali saat ProductsPage dibuka + saat user refresh.
  Future<void> refresh() async {
    if (loadingNotifier.value) return;
    loadingNotifier.value = true;
    try {
      // Coba Dio langsung agar terlihat pemakaian kedua package.
      try {
        final viaDio =
            await ApiService.instance.fetchProductsWithDio();
        if (viaDio.isNotEmpty) {
          productsNotifier.value = viaDio;
          sourceNotifier.value = 'Online • Dio';
          return;
        }
      } catch (_) {
        // fallback ke http
      }
      try {
        final viaHttp =
            await ApiService.instance.fetchProductsWithHttp();
        if (viaHttp.isNotEmpty) {
          productsNotifier.value = viaHttp;
          sourceNotifier.value = 'Online • HTTP';
          return;
        }
      } catch (_) {
        // fallback lokal
      }
      productsNotifier.value = List.of(local.products);
      sourceNotifier.value = 'Offline • Lokal';
    } finally {
      loadingNotifier.value = false;
    }
  }
}
