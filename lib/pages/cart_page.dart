import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CartItem> cart = ref.watch(cartProvider);
    final int totalPrice = ref.watch(cartTotalPriceProvider);
    final int totalQty = ref.watch(cartTotalQuantityProvider);

    // Mock biaya & diskon seperti desain (40% + delivery)
    const int deliveryFee = 15000;
    final int discount = cart.isEmpty ? 0 : (totalPrice * 0.4).round();
    final int checkoutTotal = cart.isEmpty ? 0 : (totalPrice - discount + deliveryFee);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: InkWell(
              onTap: () {
                if (context.canPop()) context.pop();
                else context.go('/home');
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              ),
            ),
          ),
        ),
        title: Text(
          'My cart',
          style: GoogleFonts.poppins(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.more_horiz, color: Colors.black, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: cart.isEmpty
          ? _EmptyCart(onBrowse: () => context.go('/home'))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    itemCount: cart.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _CartTile(item: cart[index]),
                  ),
                ),
                _CartSummary(
                  totalPrice: totalPrice,
                  totalQty: totalQty,
                  deliveryFee: deliveryFee,
                  discount: discount,
                  checkoutTotal: checkoutTotal,
                ),
              ],
            ),
    );
  }
}

class _CartTile extends ConsumerWidget {
  final CartItem item;
  const _CartTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = item.product;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 84,
            height: 86,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              p.image,
              fit: BoxFit.cover,
              errorBuilder: (_, e, s) => Container(
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Icon(Icons.image_outlined, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.black, height: 1.1),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Size ${item.size} • ${p.category}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        ref.read(cartProvider.notifier).removeItem(item);
                        Fluttertoast.showToast(msg: '${p.name} dihapus dari cart', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.close, size: 16, color: Colors.grey.shade400),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      p.priceText,
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _QtyButton(
                          icon: Icons.remove,
                          isActive: false,
                          onTap: () => ref.read(cartProvider.notifier).decreaseQuantity(p.id, size: item.size),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text('${item.quantity}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                        _QtyButton(
                          icon: Icons.add,
                          isActive: true,
                          onTap: () => ref.read(cartProvider.notifier).increaseQuantity(p.id, size: item.size),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  const _QtyButton({required this.icon, required this.onTap, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: isActive ? const Color(0xFFFFC72C) : Colors.grey.shade300, width: isActive ? 1.4 : 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: isActive ? Colors.black : Colors.grey.shade600),
      ),
    );
  }
}

class _CartSummary extends ConsumerWidget {
  final int totalPrice;
  final int totalQty;
  final int deliveryFee;
  final int discount;
  final int checkoutTotal;
  const _CartSummary({required this.totalPrice, required this.totalQty, required this.deliveryFee, required this.discount, required this.checkoutTotal});

  static const _yellow = Color(0xFFFFC72C);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Color(0x0F000000), blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Promocode row - seperti desain ADJ3AK
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text('ADJ3AK', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black, letterSpacing: 0.8)),
                  const Spacer(),
                  Row(
                    children: [
                      Text('Promocode applied', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFFB8860B))),
                      const SizedBox(width: 6),
                      Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(color: _yellow, shape: BoxShape.circle),
                        child: const Icon(Icons.check, size: 12, color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SummaryRow(label: 'Subtotal:', value: Product.priceTextStatic(totalPrice)),
            const SizedBox(height: 6),
            _SummaryRow(label: 'Delivery Fee:', value: Product.priceTextStatic(deliveryFee)),
            const SizedBox(height: 6),
            _SummaryRow(label: 'Discount:', value: '40%'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  if (ref.watch(cartProvider).isEmpty) {
                    Fluttertoast.showToast(msg: 'Cart masih kosong', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
                    return;
                  }
                  context.push('/checkout');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _yellow,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Checkout for ${Product.priceTextStatic(checkoutTotal)}',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
        const Spacer(),
        Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final VoidCallback onBrowse;
  const _EmptyCart({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              alignment: Alignment.center,
              child: Icon(Icons.shopping_bag_outlined, size: 42, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            Text('Cart masih kosong', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Yuk, lihat produk dan tambahkan favoritmu ke cart.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 18),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onBrowse,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC72C), foregroundColor: Colors.black, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 28), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('Lihat Produk', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
