import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import '../data/products.dart' as local;
import '../models/product.dart';

/// Layer jaringan yang memakai **dio** sebagai client utama
/// dan **http** sebagai fallback.
///
/// Endpoint demo: FakeStore API. Kalau offline / gagal,
/// otomatis fallback ke katalog lokal ([local.products])
/// supaya aplikasi tetap jalan.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  static const String _baseUrl = 'https://fakestoreapi.com';
  static const Duration _timeout = Duration(seconds: 12);

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
      headers: {'Accept': 'application/json'},
    ),
  );

  /// Ambil produk memakai **dio**.
  Future<List<Product>> fetchProductsWithDio() async {
    final res = await _dio.get('/products');
    final data = res.data;
    if (data is List) {
      return data
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    throw const FormatException('Respon dio tidak valid');
  }

  /// Ambil produk memakai **http** (package:http).
  Future<List<Product>> fetchProductsWithHttp() async {
    final res = await http
        .get(Uri.parse('$_baseUrl/products'))
        .timeout(_timeout);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }
    final decoded = jsonDecode(res.body);
    if (decoded is List) {
      return decoded
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    throw const FormatException('Respon http tidak valid');
  }

  /// Coba dio dulu, lalu http, terakhir fallback lokal.
  /// Tidak pernah throw — selalu mengembalikan list.
  Future<List<Product>> fetchProducts() async {
    try {
      final remote = await fetchProductsWithDio();
      if (remote.isNotEmpty) return remote;
    } catch (_) {
      // lanjut ke http
    }
    try {
      final remote = await fetchProductsWithHttp();
      if (remote.isNotEmpty) return remote;
    } catch (_) {
      // lanjut ke lokal
    }
    return local.products;
  }

  /// Filter + search murni Dart (dipakai semua halaman).
  static List<Product> filter({
    required List<Product> source,
    String category = 'All',
    String query = '',
  }) {
    final q = query.trim().toLowerCase();
    return source.where((p) {
      final matchCategory =
          category == 'All' || p.category == category;
      final matchQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
      return matchCategory && matchQuery;
    }).toList();
  }
}
