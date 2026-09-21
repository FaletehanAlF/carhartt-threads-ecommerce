import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../services/favorites.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  String selectedSize = 'M';
  int qty = 1;
  bool _descExpanded = false;

  static const sizes = ['S', 'M', 'L', 'XL'];
  static const _primary = Color(0xFFFFC72C);

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final cartCount = ref.watch(cartTotalQuantityProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 22),
            tooltip: 'Back',
          ),
        ),
        actions: [
          ValueListenableBuilder<Set<int>>(
            valueListenable: favoriteProductIds,
            builder: (context, favs, _) {
              final fav = favs.contains(p.id);
              return IconButton(
                onPressed: () {
                  toggleFavoriteId(p.id);
                  Fluttertoast.showToast(
                    msg: fav ? '${p.name} dihapus dari favorite' : '${p.name} ditambahkan ke favorite',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                },
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    fav ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey(fav),
                    color: fav ? const Color(0xFFE53935) : Colors.black,
                    size: 22,
                  ),
                ),
                tooltip: fav ? 'Remove from favorites' : 'Add to favorites',
              );
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () => context.push('/cart'),
                icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black, size: 22),
                tooltip: 'Cart',
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(10)),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    alignment: Alignment.center,
                    child: Text(
                      cartCount > 99 ? '99+' : '$cartCount',
                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.black, height: 1),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 24 + MediaQuery.of(context).padding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image - clean large with rounded
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF2F2F2),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      p.image,
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
                      errorBuilder: (_, e, s) => const Center(child: Icon(Icons.image_outlined, size: 48, color: Color(0xFFBDBDBD))),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.category.toUpperCase(),
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade500, letterSpacing: 0.9),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.name,
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF111111), height: 1.25),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.priceText,
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF111111)),
                  ),
                  const SizedBox(height: 20),
                  // Description
                  Text('Description', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
                  const SizedBox(height: 8),
                  _DescriptionText(text: p.description, expanded: _descExpanded, onToggle: () => setState(() => _descExpanded = !_descExpanded)),
                  const SizedBox(height: 24),
                  // Size
                  Text('Size', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
                  const SizedBox(height: 12),
                  Row(
                    children: sizes.map((s) {
                      final sel = s == selectedSize;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () => setState(() => selectedSize = s),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            width: 52,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: sel ? _primary : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: sel ? _primary : const Color(0xFFE0E0E0), width: sel ? 1.4 : 1),
                            ),
                            child: Text(s, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Quantity
                  Row(
                    children: [
                      Text('Quantity', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
                      const Spacer(),
                      _QtyBtn(
                        icon: Icons.remove,
                        onTap: () {
                          if (qty > 1) setState(() => qty--);
                        },
                      ),
                      Container(
                        width: 40,
                        alignment: Alignment.center,
                        child: Text('$qty', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
                      ),
                      _QtyBtn(
                        icon: Icons.add,
                        onTap: () => setState(() => qty++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              ValueListenableBuilder<Set<int>>(
                valueListenable: favoriteProductIds,
                builder: (context, favs, _) {
                  final fav = favs.contains(p.id);
                  return SizedBox(
                    width: 52,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        toggleFavoriteId(p.id);
                        Fluttertoast.showToast(
                          msg: fav ? '${p.name} dihapus dari favorite' : '${p.name} ditambahkan ke favorite',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.white,
                      ),
                      child: Icon(fav ? Icons.favorite : Icons.favorite_border, color: fav ? const Color(0xFFE53935) : Colors.black, size: 22),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(cartProvider.notifier).addProduct(p, quantity: qty, size: selectedSize);
                      Fluttertoast.showToast(
                        msg: '$qty x ${p.name} (Size $selectedSize) ditambahkan ke tas',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Add to Bag', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DescriptionText extends StatelessWidget {
  final String text;
  final bool expanded;
  final VoidCallback onToggle;
  const _DescriptionText({required this.text, required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    const threshold = 140;
    final needCollapse = text.length > threshold;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Text(text, maxLines: 3, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF5A5A5A), height: 1.65)),
          secondChild: Text(text, style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF5A5A5A), height: 1.65)),
          crossFadeState: expanded || !needCollapse ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        if (needCollapse) ...[
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onToggle,
            child: Text(expanded ? 'Show less' : 'Read more', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF111111))),
          ),
        ],
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

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
