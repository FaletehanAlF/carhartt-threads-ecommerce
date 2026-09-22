import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/products.dart' as local;
import '../models/product.dart';

/// Layer jaringan untuk Carhartt Shop.
///
/// Prioritas:
/// 1. Carhartt API lokal — 20 produk demo
/// 2. FakeStore API (fallback lama, hanya untuk debugging dicatat)
/// 3. Katalog lokal (offline)
///
/// Dio sebagai client utama, http sebagai fallback.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // Carhartt API lokal - coba beberapa host untuk Android emulator & physical device
  // localhost -> Chrome/Windows, 10.0.2.2 -> Android emulator, 10.167.20.81 -> physical device Infinix
  static const List<String> _carharttHosts = [
    'http://localhost:3000',
    'http://10.0.2.2:3000',
    'http://10.167.20.81:3000',
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
  Future<List<Product>> fetchProductsFromCarhartt({String? category}) async {
    for (final host in _carharttHosts) {
      try {
        final url = category == null || category == 'All'
            ? '$host/api/products'
            : '$host/api/products?category=${Uri.encodeComponent(category)}';
        debugPrint('TRY Carhartt Dio: $url');
        final res = await _dio.get(url);
        debugPrint('API STATUS: ${res.statusCode}');
        debugPrint('API DATA TYPE: ${res.data.runtimeType}');
        // Jangan print seluruh data jika besar, cukup preview
        final preview = res.data.toString();
        debugPrint('API DATA preview: ${preview.length > 300 ? preview.substring(0, 300) : preview}');
        final parsed = _parseCarharttResponse(res.data, host);
        debugPrint('PRODUCT COUNT: ${parsed.length}');
        if (parsed.isNotEmpty) {
          final first = parsed.first;
          debugPrint('PRODUCT 1: id=${first.id} name=${first.name}');
          debugPrint('RATING TYPE: ${first.rating.runtimeType}');
          debugPrint('RATING VALUE: ${first.rating}');
          debugPrint('PRICE TYPE: ${first.price.runtimeType}');
          debugPrint('PRICE VALUE: ${first.price}');
          debugPrint('IMAGE: ${first.image}');
          debugPrint('SIZES: ${first.sizes}');
          return parsed;
        }
      } catch (e, st) {
        debugPrint('Carhartt Dio FAILED host=$host error=$e');
        debugPrint('STACK: $st');
        continue;
      }
    }
    debugPrint('Carhartt API tidak terjangkau di semua host: $_carharttHosts');
    throw Exception('Carhartt API tidak terjangkau');
  }

  Future<List<Product>> fetchProductsFromCarharttWithHttp({String? category}) async {
    for (final host in _carharttHosts) {
      try {
        final url = category == null || category == 'All'
            ? '$host/api/products'
            : '$host/api/products?category=${Uri.encodeComponent(category)}';
        debugPrint('TRY Carhartt HTTP: $url');
        final res = await http.get(Uri.parse(url)).timeout(_timeout);
        debugPrint('HTTP STATUS: ${res.statusCode}');
        debugPrint('HTTP BODY TYPE: ${res.body.runtimeType}');
        if (res.statusCode != 200) {
          debugPrint('HTTP non-200, continue');
          continue;
        }
        final decoded = jsonDecode(res.body);
        debugPrint('DECODED TYPE: ${decoded.runtimeType}');
        final parsed = _parseCarharttResponse(decoded, host);
        debugPrint('HTTP PRODUCT COUNT: ${parsed.length}');
        if (parsed.isNotEmpty) return parsed;
      } catch (e, st) {
        debugPrint('Carhartt HTTP FAILED host=$host error=$e');
        debugPrint('STACK: $st');
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
        debugPrint('fetchProductById $id host=$host dataType=${data.runtimeType}');
        if (data is Map && data['success'] == true && data['data'] is Map) {
          return Product.fromJson(Map<String, dynamic>.from(data['data'] as Map));
        }
      } catch (e) {
        debugPrint('fetchProductById failed host=$host id=$id error=$e');
        continue;
      }
    }
    return null;
  }

  List<Product> _parseCarharttResponse(dynamic body, String source) {
    debugPrint('_parseCarharttResponse source=$source bodyType=${body.runtimeType}');
    // Format: {success:true, data:[...]} atau {success:true, data:{...}}
    if (body is Map && body['data'] is List) {
      final list = body['data'] as List;
      debugPrint('Wrapper Map with List data length=${list.length}');
      return _parseListToProducts(list, source);
    }
    if (body is List) {
      debugPrint('Body is direct List length=${body.length} (FakeStore fallback)');
      return _parseListToProducts(body, source);
    }
    debugPrint('Format tidak valid body=$body');
    throw FormatException('Format $source tidak valid');
  }

  // ── FakeStore fallback (hanya jika Carhartt gagal, dicatat) ──

  Future<List<Product>> fetchProductsWithDio() async {
    // Coba Carhartt dulu
    try {
      final carhartt = await fetchProductsFromCarhartt();
      if (carhartt.isNotEmpty) return carhartt;
    } catch (e) {
      debugPrint('fetchProductsWithDio Carhartt FAILED: $e — akan coba FakeStore');
    }
    // Fallback FakeStore — dicatat agar tidak diam-diam
    debugPrint('FALLBACK ke FakeStore Dio');
    final res = await _dio.get('$_fakeStoreBase/products');
    debugPrint('FakeStore STATUS: ${res.statusCode} TYPE: ${res.data.runtimeType}');
    return _parseToProducts(res.data, 'dio-fakestore');
  }

  Future<List<Product>> fetchProductsWithHttp() async {
    try {
      final carhartt = await fetchProductsFromCarharttWithHttp();
      if (carhartt.isNotEmpty) return carhartt;
    } catch (e) {
      debugPrint('fetchProductsWithHttp Carhartt FAILED: $e — akan coba FakeStore');
    }
    debugPrint('FALLBACK ke FakeStore HTTP');
    final res = await http.get(Uri.parse('$_fakeStoreBase/products')).timeout(_timeout);
    debugPrint('FakeStore HTTP STATUS: ${res.statusCode}');
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    return _parseToProducts(jsonDecode(res.body), 'http-fakestore');
  }

  List<Product> _parseToProducts(dynamic data, String source) {
    debugPrint('_parseToProducts source=$source dataType=${data.runtimeType}');
    if (data is Map && data['data'] is List) {
      debugPrint('Wrapper Map detected');
      return _parseListToProducts(data['data'] as List, source);
    }
    if (data is! List) throw FormatException('Respon $source tidak valid: ${data.runtimeType}');
    return _parseListToProducts(data, source);
  }

  List<Product> _parseListToProducts(List data, String source) {
    debugPrint('_parseListToProducts source=$source length=${data.length}');
    final items = <Product>[];
    for (int i = 0; i < data.length; i++) {
      final e = data[i];
      if (e is Map) {
        try {
          final product = Product.fromJson(Map<String, dynamic>.from(e));
          // Debug per product pertama
          if (i == 0) {
            debugPrint('First parsed product: id=${product.id} rating=${product.rating}(${product.rating.runtimeType}) price=${product.price}(${product.price.runtimeType}) image=${product.image} sizes=${product.sizes}');
          }
          items.add(product);
        } catch (e, st) {
          debugPrint('SKIP invalid product index=$i error=$e');
          debugPrint('STACK: $st');
          debugPrint('RAW: $e');
          // Fallback agar grid tidak crash: buat product dengan default
          // sesuai instruksi: rating 0.0, price 0, image "", sizes default
          try {
            final fallbackJson = Map<String, dynamic>.from(e as Map);
            fallbackJson['rating'] = (fallbackJson['rating'] as num?)?.toDouble() ?? 0.0;
            fallbackJson['price'] = (fallbackJson['price'] as num?)?.toInt() ?? 0;
            fallbackJson['image'] ??= '';
            fallbackJson['description'] ??= '';
            fallbackJson['sizes'] ??= ["S", "M", "L", "XL"];
            items.add(Product.fromJson(fallbackJson));
            debugPrint('Added fallback product for index $i');
          } catch (_) {
            debugPrint('Fallback also failed for index $i, skip');
          }
        }
      } else {
        debugPrint('SKIP non-Map at index $i: ${e.runtimeType}');
      }
    }
    debugPrint('Parsed items count: ${items.length}');
    if (items.isEmpty) throw const FormatException('Tidak ada produk valid');
    return items;
  }

  /// Coba dio dulu, lalu http, terakhir fallback lokal.
  Future<List<Product>> fetchProducts() async {
    try {
      final remote = await fetchProductsWithDio();
      if (remote.isNotEmpty) {
        debugPrint('fetchProducts -> Dio success count=${remote.length}');
        return remote;
      }
    } catch (e, st) {
      debugPrint('fetchProducts Dio FAILED: $e');
      debugPrint('STACK: $st');
    }
    try {
      final remote = await fetchProductsWithHttp();
      if (remote.isNotEmpty) {
        debugPrint('fetchProducts -> Http success count=${remote.length}');
        return remote;
      }
    } catch (e, st) {
      debugPrint('fetchProducts Http FAILED: $e');
      debugPrint('STACK: $st');
    }
    debugPrint('FALLBACK ke lokal: ${local.products.length}');
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
