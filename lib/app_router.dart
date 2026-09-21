import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models/product.dart';
import 'pages/favoritePage.dart';
import 'pages/homePage.dart';
import 'pages/loginPage.dart';
import 'pages/product_detail_page.dart';
import 'pages/productsPage.dart';
import 'pages/profilePage.dart';
import 'pages/registerPage.dart';
import 'services/auth_service.dart';
import 'services/product_repository.dart';

/// Konfigurasi GoRouter terpusat.
///
/// Struktur route:
/// '/'              -> redirect ke '/login' (atau '/home' jika sudah login)
/// '/login'         -> [LoginPage], support ?email=xxx & extra String
/// '/register'      -> [RegisterPage]
/// '/home'          -> [HomePage] (berisi BottomNav: Home/Products/Favorites/Profile)
/// '/products'      -> [ProductsPage] (standalone, deep-linkable)
/// '/favorites'     -> [FavoritePage]
/// '/profile'       -> [ProfilePage]
/// '/product/:id'   -> [ProductDetailPage] (via extra Product atau lookup by id)
///
/// Contoh dari pub.dev diperbaiki:
/// - import yang benar adalah flutter/material.dart + go_router,
///   BUKAN package:material_ui/material_ui.dart (package itu tidak ada).
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  // Agar redirect auth otomatis refresh saat login/logout.
  refreshListenable: AuthService.instance.authNotifier,
  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn = AuthService.instance.isLoggedIn;
    final String loc = state.matchedLocation;

    const authRoutes = <String>['/login', '/register'];
    final bool isAuthRoute = authRoutes.contains(loc);
    final bool isSplash = loc == '/';

    // Belum login tapi akses halaman proteksi -> paksa ke login.
    if (!loggedIn && !isAuthRoute) {
      // Hindari loop: kalau sudah di '/', arahkan sekali saja.
      if (isSplash) return '/login';
      // Jangan redirect halaman error / product-not-found yang sudah
      // ditangani errorBuilder (matchedLocation kosong tidak terjadi di sini).
      return '/login';
    }

    // Sudah login tapi masih di login/register/splash -> ke home.
    if (loggedIn && (isAuthRoute || isSplash)) {
      return '/home';
    }

    return null; // tidak ada redirect
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        // Tidak akan lama di sini karena redirect di atas,
        // tapi sediakan fallback agar tidak blank.
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (BuildContext context, GoRouterState state) {
        // Dukung 3 cara pengiriman email:
        // 1. /login?email=xxx (deep-linkable, dipakai setelah register)
        // 2. extra sebagai String
        // 3. extra sebagai Map {'email': ...}
        final String? queryEmail = state.uri.queryParameters['email'];
        final Object? extra = state.extra;
        String? extraEmail;
        if (extra is String && extra.isNotEmpty) {
          extraEmail = extra;
        } else if (extra is Map && extra['email'] is String) {
          extraEmail = extra['email'] as String;
        }
        return LoginPage(
          initialEmail: queryEmail ?? extraEmail,
        );
      },
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterPage();
      },
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'product/:id',
          name: 'product-from-home',
          builder: (BuildContext context, GoRouterState state) {
            return _buildProductDetail(state);
          },
        ),
      ],
    ),
    // Standalone routes (deep-linkable, tetap bisa dibuka langsung).
    GoRoute(
      path: '/products',
      name: 'products',
      builder: (BuildContext context, GoRouterState state) {
        return const ProductsPage();
      },
    ),
    GoRoute(
      path: '/favorites',
      name: 'favorites',
      builder: (BuildContext context, GoRouterState state) {
        return const FavoritePage();
      },
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (BuildContext context, GoRouterState state) {
        return const ProfilePage();
      },
    ),
    GoRoute(
      path: '/product/:id',
      name: 'product-detail',
      builder: (BuildContext context, GoRouterState state) {
        return _buildProductDetail(state);
      },
    ),
  ],
  errorBuilder: (BuildContext context, GoRouterState state) {
    return Scaffold(
      appBar: AppBar(title: const Text('Halaman tidak ditemukan')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'Route ${state.uri.toString()} tidak ditemukan.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Kembali ke Home'),
            ),
          ],
        ),
      ),
    );
  },
);

/// Helper: bangun [ProductDetailPage] dari path param + extra.
///
/// Prioritas:
/// 1. extra is Product -> langsung pakai (tanpa lookup, anti bug saat
///    list belum selesai refresh dari server).
/// 2. lookup ProductRepository.byId(id).
/// 3. Kalau tetap null -> tampilkan halaman error yang aman (tidak crash).
Widget _buildProductDetail(GoRouterState state) {
  final Object? extra = state.extra;
  if (extra is Product) {
    return ProductDetailPage(product: extra);
  }

  final String? idRaw = state.pathParameters['id'];
  final int? id = int.tryParse(idRaw ?? '');
  if (id != null) {
    final Product? found = ProductRepository.instance.byId(id);
    if (found != null) {
      return ProductDetailPage(product: found);
    }
  }

  return Scaffold(
    appBar: AppBar(title: const Text('Produk tidak ditemukan')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Text('Produk dengan id "$idRaw" tidak ditemukan.'),
          const SizedBox(height: 16),
          Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Kembali ke Home'),
              );
            },
          ),
        ],
      ),
    ),
  );
}
