import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../services/favorites.dart';

/// Halaman detail produk.
///
/// Alur data (biar mudah dipahami pemula):
/// 1. Data produk berasal dari `widget.product` (dikirim via GoRouter extra).
/// 2. Status favorit berasal dari `favoriteProductIds` (ValueNotifier global).
/// 3. Jumlah item di cart berasal dari `cartTotalQuantityProvider` (Riverpod).
/// 4. State lokal (size & quantity) disimpan di State ini via setState.
/// 5. User menekan tombol -> handler `_handle...` dipanggil.
/// 6. Handler mengubah state/provider -> UI otomatis rebuild.
class ProductDetailPage extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  // ---------- State lokal ----------
  // Dipilih user di halaman ini, belum masuk ke cart sampai tekan Add to Bag.
  String selectedSize = 'M';
  int selectedQuantity = 1;
  bool isDescriptionExpanded = false;

  static const List<String> availableSizes = ['S', 'M', 'L', 'XL'];
  static const Color primaryYellow = Color(0xFFFFC72C);

  // ---------- Event handlers ----------
  // Setiap tombol di UI memanggil salah satu handler di bawah ini.
  // Tujuannya: onPressed jadi pendek dan jelas (contoh: onPressed: _handleAddToCart).

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _handleGoToCart() {
    context.push('/cart');
  }

  void _handleSelectSize(String size) {
    setState(() => selectedSize = size);
  }

  void _handleIncreaseQuantity() {
    setState(() => selectedQuantity++);
  }

  void _handleDecreaseQuantity() {
    // Cart tidak mengizinkan quantity 0, jadi minimal 1.
    if (selectedQuantity > 1) {
      setState(() => selectedQuantity--);
    }
  }

  void _handleToggleDescription() {
    setState(() => isDescriptionExpanded = !isDescriptionExpanded);
  }

  void _handleToggleFavorite({
    required bool isCurrentlyFavorite,
    required Product product,
  }) {
    toggleFavoriteId(product.id);
    _showFavoriteMessage(
      wasFavorite: isCurrentlyFavorite,
      productName: product.name,
    );
  }

  void _showFavoriteMessage({
    required bool wasFavorite,
    required String productName,
  }) {
    final String message = wasFavorite
        ? '$productName dihapus dari favorite'
        : '$productName ditambahkan ke favorite';

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleAddToCart() {
    final Product product = widget.product;

    // Logic cart tetap sama: tambah produk + size + quantity ke Riverpod.
    ref.read(cartProvider.notifier).addProduct(
          product,
          quantity: selectedQuantity,
          size: selectedSize,
        );

    Fluttertoast.showToast(
      msg: '$selectedQuantity x ${product.name} (Size $selectedSize) ditambahkan ke tas',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    // 1. Data produk berasal dari widget (dikirim via routing).
    final Product product = widget.product;

    // 2. Jumlah item di cart berasal dari Riverpod (otomatis rebuild jika berubah).
    final int cartItemCount = ref.watch(cartTotalQuantityProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F8),
      appBar: _buildAppBar(product: product, cartItemCount: cartItemCount),
      body: _buildBody(product: product),
      bottomNavigationBar: _buildBottomBar(product: product),
    );
  }

  // ---------- AppBar ----------
  AppBar _buildAppBar({
    required Product product,
    required int cartItemCount,
  }) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: IconButton(
          onPressed: _handleBack,
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 22),
          tooltip: 'Back',
        ),
      ),
      actions: [
        _buildFavoriteAction(product: product),
        _buildCartAction(cartItemCount: cartItemCount),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildFavoriteAction({required Product product}) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: favoriteProductIds,
      builder: (context, favoriteIds, _) {
        final bool isFavorite = favoriteIds.contains(product.id);

        return IconButton(
          onPressed: () => _handleToggleFavorite(
            isCurrentlyFavorite: isFavorite,
            product: product,
          ),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(isFavorite),
              color: isFavorite ? const Color(0xFFE53935) : Colors.black,
              size: 22,
            ),
          ),
          tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
        );
      },
    );
  }

  Widget _buildCartAction({required int cartItemCount}) {
    final bool hasItemsInCart = cartItemCount > 0;

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          onPressed: _handleGoToCart,
          icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black, size: 22),
          tooltip: 'Cart',
        ),
        if (hasItemsInCart)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: primaryYellow,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              alignment: Alignment.center,
              child: Text(
                cartItemCount > 99 ? '99+' : '$cartItemCount',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ---------- Body ----------
  Widget _buildBody({required Product product}) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 24 + MediaQuery.of(context).padding.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImage(product: product),
          const SizedBox(height: 20),
          _buildProductInfo(product: product),
        ],
      ),
    );
  }

  Widget _buildProductImage({required Product product}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          color: const Color(0xFFF2F2F2),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              product.image,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (_, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.image_outlined, size: 48, color: Color(0xFFBDBDBD)),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo({required Product product}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.category.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            product.name,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111111),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.priceText,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 20),
          _buildDescriptionSection(description: product.description),
          const SizedBox(height: 24),
          _buildSizeSelector(),
          const SizedBox(height: 24),
          _buildQuantitySelector(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection({required String description}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        const SizedBox(height: 8),
        _DescriptionText(
          text: description,
          isExpanded: isDescriptionExpanded,
          onToggle: _handleToggleDescription,
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Size', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
        const SizedBox(height: 12),
        Row(
          children: availableSizes.map((size) {
            final bool isSelected = size == selectedSize;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => _handleSelectSize(size),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: 52,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? primaryYellow : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? primaryYellow : const Color(0xFFE0E0E0),
                      width: isSelected ? 1.4 : 1,
                    ),
                  ),
                  child: Text(
                    size,
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        Text('Quantity', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
        const Spacer(),
        _QuantityButton(
          icon: Icons.remove,
          onTap: _handleDecreaseQuantity,
        ),
        Container(
          width: 40,
          alignment: Alignment.center,
          child: Text(
            '$selectedQuantity',
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
          ),
        ),
        _QuantityButton(
          icon: Icons.add,
          onTap: _handleIncreaseQuantity,
        ),
      ],
    );
  }

  // ---------- Bottom bar ----------
  Widget _buildBottomBar({required Product product}) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            _buildBottomFavoriteButton(product: product),
            const SizedBox(width: 12),
            _buildAddToBagButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomFavoriteButton({required Product product}) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: favoriteProductIds,
      builder: (context, favoriteIds, _) {
        final bool isFavorite = favoriteIds.contains(product.id);

        return SizedBox(
          width: 52,
          height: 52,
          child: OutlinedButton(
            onPressed: () => _handleToggleFavorite(
              isCurrentlyFavorite: isFavorite,
              product: product,
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.white,
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? const Color(0xFFE53935) : Colors.black,
              size: 22,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddToBagButton() {
    return Expanded(
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: _handleAddToCart,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryYellow,
            foregroundColor: Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Add to Bag',
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
          ),
        ),
      ),
    );
  }
}

// ---------- Widget kecil pendukung ----------
// Dipisah agar build() tidak terlalu panjang, tapi tetap di file yang sama
// supaya mudah dilacak pemula (tidak perlu buka file lain).

class _DescriptionText extends StatelessWidget {
  final String text;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _DescriptionText({
    required this.text,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    const int collapseThreshold = 140;
    final bool needsCollapseButton = text.length > collapseThreshold;
    final bool showFullText = isExpanded || !needsCollapseButton;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF5A5A5A), height: 1.65),
          ),
          secondChild: Text(
            text,
            style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF5A5A5A), height: 1.65),
          ),
          crossFadeState: showFullText ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        if (needsCollapseButton) ...[
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onToggle,
            child: Text(
              isExpanded ? 'Show less' : 'Read more',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF111111)),
            ),
          ),
        ],
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.white,
        ),
        child: Icon(icon, size: 16, color: Colors.black),
      ),
    );
  }
}
