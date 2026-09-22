import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import '../data/products.dart' as local;
import '../models/product.dart';

/// Layer jaringan untuk Carhartt Shop.
///
/// Prioritas:
/// 1. Carhartt API lokal (http://localhost:3000 / 10.0.2.2:3000) — 20 produk demo
/// 2. FakeStore API (fallback lama)
/// 3. Katalog lokal (offline)
///
/// Dio sebagai client utama, http sebagai fallback.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // Carhartt API lokal - coba beberapa host untuk Android emulator & Web
  static const List<String> _carharttHosts = [
    'http://localhost:3000',
    'http://10.0.2.2:3000',
    'http://127.0.0.1:3000',
  ];

  static const String _fakeStoreBase = 'https://fakestoreapi.com';
  static const Duration _timeout = Duration(seconds: 10);

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
      headers: {'Accept': 'application/json'},
    ),
  );

  // ── Carhartt API ──

  /// Ambil semua produk dari Carhartt API (GET /api/products)
  /// Mendukung filter ?category=T-Shirt (opsional, tapi client juga filter lokal)
  Future<List<Product>> fetchProductsFromCarhartt({String? category}) async {
    for (final host in _carharttHosts) {
      try {
        final url = category == null || category == 'All'
            ? '$host/api/products'
            : '$host/api/products?category=${Uri.encodeComponent(category)}';
        final res = await _dio.get(url);
        final parsed = _parseCarharttResponse(res.data, host);
        if (parsed.isNotEmpty) return parsed;
      } catch (_) {
        continue;
      }
    }
    throw Exception('Carhartt API tidak terjangkau');
  }

  Future<List<Product>> fetchProductsFromCarharttWithHttp({String? category}) async {
    for (final host in _carharttHosts) {
      try {
        final url = category == null || category == 'All'
            ? '$host/api/products'
            : '$host/api/products?category=${Uri.encodeComponent(category)}';
        final res = await http.get(Uri.parse(url)).timeout(_timeout);
        if (res.statusCode != 200) continue;
        final decoded = jsonDecode(res.body);
        final parsed = _parseCarharttResponse(decoded, host);
        if (parsed.isNotEmpty) return parsed;
      } catch (_) {
        continue;
      }
    }
    throw Exception('Carhartt API http gagal');
  }

  /// Ambil 1 produk by id dari Carhartt API
  Future<Product?> fetchProductById(int id) async {
    for (final host in _carharttHosts) {
      try {
        final res = await _dio.get('$host/api/products/$id');
        final data = res.data;
        if (data is Map && data['success'] == true && data['data'] is Map) {
          return Product.fromJson(Map<String, dynamic>.from(data['data'] as Map));
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  List<Product> _parseCarharttResponse(dynamic body, String source) {
    // Format: {success:true, data:[...]} atau {success:true, data:{...}}
    if (body is Map && body['data'] is List) {
      final list = body['data'] as List;
      return _parseListToProducts(list, source);
    }
    if (body is List) {
      // Fallback kalau response langsung List (FakeStore)
      return _parseListToProducts(body, source);
    }
    throw FormatException('Format $source tidak valid');
  }

  // ── FakeStore fallback (tetap dipertahankan) ──

  Future<List<Product>> fetchProductsWithDio() async {
    // Coba Carhartt dulu
    try {
      final carhartt = await fetchProductsFromCarhartt();
      if (carhartt.isNotEmpty) return carhartt;
    } catch (_) {}
    // Fallback FakeStore
    final res = await _dio.get('$_fakeStoreBase/products');
    return _parseToProducts(res.data, 'dio');
  }

  Future<List<Product>> fetchProductsWithHttp() async {
    try {
      final carhartt = await fetchProductsFromCarharttWithHttp();
      if (carhartt.isNotEmpty) return carhartt;
    } catch (_) {}
    final res = await http.get(Uri.parse('$_fakeStoreBase/products')).timeout(_timeout);
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    return _parseToProducts(jsonDecode(res.body), 'http');
  }

  List<Product> _parseToProducts(dynamic data, String source) {
    if (data is Map && data['data'] is List) {
      return _parseListToProducts(data['data'] as List, source);
    }
    if (data is! List) throw FormatException('Respon $source tidak valid');
    return _parseListToProducts(data, source);
  }

  List<Product> _parseListToProducts(List data, String source) {
    final items = <Product>[];
    for (final e in data) {
      if (e is Map) {
        try {
          items.add(Product.fromJson(Map<String, dynamic>.from(e)));
        } catch (_) {}
      }
    }
    if (items.isEmpty) throw const FormatException('Tidak ada produk valid');
    return items;
  }

  /// Coba dio dulu, lalu http, terakhir fallback lokal.
  Future<List<Product>> fetchProducts() async {
    try {
      final remote = await fetchProductsWithDio();
      if (remote.isNotEmpty) return remote;
    } catch (_) {}
    try {
      final remote = await fetchProductsWithHttp();
      if (remote.isNotEmpty) return remote;
    } catch (_) {}
    return List<Product>.from(local.products);
  }

  /// Filter + search murni Dart (dipakai semua halaman).
  static List<Product> filter({
    required List<Product> source,
    String category = 'All',
    String query = '',
  }) {
    final q = query.trim().toLowerCase();
    return source.where((p) {
      final matchCategory = category == 'All' || p.category == category;
      final matchQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
      return matchCategory && matchQuery;
    }).toList();
  }
}
