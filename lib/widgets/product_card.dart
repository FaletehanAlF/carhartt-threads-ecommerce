import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/product.dart';
import '../services/favorites.dart';

/// Kartu produk reusable — dipakai di Home, Products, Favorites.
///
/// Alur favorit (biar mudah dipahami pemula):
/// 1. Data favorit berasal dari `favoriteProductIds` (ValueNotifier global).
/// 2. UI watch via `ValueListenableBuilder` -> rebuild otomatis saat favorit berubah.
/// 3. User tap ikon hati -> `_handleToggleFavorite()` dipanggil.
/// 4. Handler mengubah `favoriteProductIds` -> UI icon berubah.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  void _handleToggleFavorite({
    required Product product,
    required bool isCurrentlyFavorite,
  }) {
    toggleFavoriteId(product.id);

    final String message = isCurrentlyFavorite
        ? '${product.name} dihapus dari favorite'
        : '${product.name} ditambahkan ke favorite';

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: favoriteProductIds,
      builder: (context, favoriteIds, child) {
        // Tentukan apakah produk ini sedang difavoritkan.
        final bool isFavorite = favoriteIds.contains(product.id);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      _buildProductImage(),
                      _buildFavoriteButton(
                        isFavorite: isFavorite,
                        product: product,
                      ),
                    ],
                  ),
                ),
                _buildProductInfo(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Image.network(
        product.image,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.image_outlined, size: 40, color: Colors.grey),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteButton({
    required bool isFavorite,
    required Product product,
  }) {
    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: IconButton(
          onPressed: () => _handleToggleFavorite(
            product: product,
            isCurrentlyFavorite: isFavorite,
          ),
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Text(
                product.category,
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
              ),
              const Spacer(),
              const Icon(Icons.star, size: 12, color: Color(0xFFB8860B)),
              const SizedBox(width: 3),
              Text(
                product.rating.toStringAsFixed(1),
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            product.priceText,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFB8860B),
            ),
          ),
        ],
      ),
    );
  }
}
