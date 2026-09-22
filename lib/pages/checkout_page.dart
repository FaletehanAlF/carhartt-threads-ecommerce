import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';

const int flatShippingCost = 10000;

/// Halaman Checkout — data produk 100% dari [cartProvider] (Riverpod).
///
/// Logic tetap sama seperti sebelumnya:
/// - Baca state: ref.watch(cartProvider) / cartTotalPriceProvider
/// - Form alamat + metode pembayaran = local state
/// - Pesanan dibuat dengan status "Berhasil"
class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final zipController = TextEditingController();

  String selectedPaymentMethod = availablePaymentMethods.first;

  static const _primary = Color(0xFFFFC72C);
  static const _bg = Color(0xFFF7F7F5);
  static const _border = Color(0xFFE9E9E7);

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    zipController.dispose();
    super.dispose();
  }

  void _handleSelectPaymentMethod(String method) {
    setState(() => selectedPaymentMethod = method);
  }

  void _payNow({
    required List<CartItem> cart,
    required int subtotal,
    required int shipping,
    required int total,
  }) {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        zipController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi alamat pengiriman terlebih dahulu.')),
      );
      return;
    }
    if (cart.isEmpty) return;
    if (!availablePaymentMethods.contains(selectedPaymentMethod)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih metode pembayaran.')),
      );
      return;
    }

    final order = ref.read(ordersProvider.notifier).placeOrder(
          items: cart,
          receiverName: nameController.text,
          phone: phoneController.text,
          address: addressController.text,
          city: cityController.text,
          zip: zipController.text,
          subtotal: subtotal,
          shipping: shipping,
          total: total,
          paymentMethod: selectedPaymentMethod,
          status: orderStatusSuccess,
        );

    ref.read(cartProvider.notifier).clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pesanan ${order.id} berhasil! Total ${Product.priceTextStatic(total)} via ${order.paymentMethod}.'),
      ),
    );
    context.go('/orders');
  }

  @override
  Widget build(BuildContext context) {
    final List<CartItem> cart = ref.watch(cartProvider);
    final int subtotal = ref.watch(cartTotalPriceProvider);
    final int totalQty = ref.watch(cartTotalQuantityProvider);
    const int shipping = flatShippingCost;
    final int total = subtotal + shipping;

    if (cart.isEmpty) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: _buildAppBar(),
        body: _EmptyCheckout(onBack: () => context.go('/cart')),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShippingAddressSection(),
            const SizedBox(height: 24),
            _buildOrderSummarySection(cart: cart, totalQty: totalQty),
            const SizedBox(height: 24),
            _buildPriceDetailsSection(
              subtotal: subtotal,
              shipping: shipping,
              total: total,
            ),
            const SizedBox(height: 24),
            _buildPaymentMethodSection(),
            const SizedBox(height: 8),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(total: total, cart: cart, subtotal: subtotal, shipping: shipping),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: () => context.canPop() ? context.pop() : context.go('/cart'),
        icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
      ),
      centerTitle: true,
      title: Text(
        'Checkout',
        style: GoogleFonts.poppins(color: const Color(0xFF111111), fontSize: 16, fontWeight: FontWeight.w600),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _border),
      ),
    );
  }

  // ───────────────── Shipping Address ─────────────────
  Widget _buildShippingAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Shipping Address', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF111111))),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              _AddressField(controller: nameController, hint: 'Nama penerima', icon: Icons.person_outline, textInputAction: TextInputAction.next),
              const SizedBox(height: 12),
              _AddressField(controller: phoneController, hint: 'Nomor telepon', icon: Icons.phone_outlined, keyboardType: TextInputType.phone, textInputAction: TextInputAction.next),
              const SizedBox(height: 12),
              _AddressField(controller: addressController, hint: 'Alamat lengkap (jalan, RT/RW, patokan)', icon: Icons.location_on_outlined, maxLines: 2, textInputAction: TextInputAction.next),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _AddressField(controller: cityController, hint: 'Kota', icon: Icons.location_city_outlined, textInputAction: TextInputAction.next),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AddressField(controller: zipController, hint: 'Kode pos', icon: Icons.local_post_office_outlined, keyboardType: TextInputType.number, textInputAction: TextInputAction.done),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────── Order Summary ─────────────────
  Widget _buildOrderSummarySection({required List<CartItem> cart, required int totalQty}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Order Summary', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF111111))),
            const SizedBox(width: 8),
            Text('($totalQty item)', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              for (int i = 0; i < cart.length; i++) ...[
                _OrderItemRow(item: cart[i]),
                if (i != cart.length - 1) Divider(height: 1, thickness: 1, color: _border.withValues(alpha: 0.7)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────── Price Details ─────────────────
  Widget _buildPriceDetailsSection({required int subtotal, required int shipping, required int total}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Price Details', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF111111))),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              _PriceRow(label: 'Subtotal', value: Product.priceTextStatic(subtotal)),
              const SizedBox(height: 10),
              _PriceRow(label: 'Shipping', value: Product.priceTextStatic(shipping)),
              const SizedBox(height: 12),
              Divider(height: 1, color: _border),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Total', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF111111))),
                  const Spacer(),
                  Text(Product.priceTextStatic(total), style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: const Color(0xFF111111))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────── Payment Method ─────────────────
  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Method', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF111111))),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              for (final method in availablePaymentMethods) ...[
                _PaymentOption(
                  method: method,
                  isSelected: method == selectedPaymentMethod,
                  onTap: () => _handleSelectPaymentMethod(method),
                ),
                if (method != availablePaymentMethods.last) const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────── Bottom Bar ─────────────────
  Widget _buildBottomBar({required int total, required List<CartItem> cart, required int subtotal, required int shipping}) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: _border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey.shade600)),
                  const SizedBox(height: 2),
                  Text(Product.priceTextStatic(total), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF111111))),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () => _payNow(cart: cart, subtotal: subtotal, shipping: shipping, total: total),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Place Order', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final CartItem item;
  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: const Color(0xFFF2F2F2),
              child: Image.network(
                product.image,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, e, s) => Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_outlined, size: 20, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF111111), height: 1.3),
                ),
                const SizedBox(height: 4),
                Text(
                  'Size ${item.size}  •  Qty ${item.quantity}',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(item.subtotalText, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF111111))),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  const _PriceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
        const Spacer(),
        Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF111111))),
      ],
    );
  }
}

class _AddressField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  const _AddressField({required this.controller, required this.hint, required this.icon, this.keyboardType, this.textInputAction, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400, color: const Color(0xFF111111)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade500),
        filled: true,
        fillColor: const Color(0xFFF9F9F7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFFC72C), width: 1.2)),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String method;
  final bool isSelected;
  final VoidCallback onTap;
  const _PaymentOption({required this.method, required this.isSelected, required this.onTap});

  IconData _icon(String m) {
    switch (m) {
      case 'DANA':
        return Icons.account_balance_wallet_outlined;
      case 'GOPAY':
        return Icons.wallet_outlined;
      case 'OVO':
        return Icons.phone_android_outlined;
      case 'CASH':
        return Icons.payments_outlined;
      default:
        return Icons.payment_outlined;
    }
  }

  String _label(String m) {
    switch (m) {
      case 'CASH':
        return 'Cash';
      default:
        return m;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFC72C).withValues(alpha: 0.14) : const Color(0xFFF9F9F7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFFFFC72C) : Colors.grey.shade200, width: isSelected ? 1.3 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
              child: Icon(_icon(method), size: 16, color: Colors.black87),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(_label(method), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF111111)))),
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, size: 20, color: isSelected ? const Color(0xFF111111) : Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _EmptyCheckout extends StatelessWidget {
  final VoidCallback onBack;
  const _EmptyCheckout({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE9E9E7))),
              child: const Icon(Icons.shopping_bag_outlined, size: 32, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text('Cart is empty', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Add products to checkout', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onBack,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC72C), foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: Text('Browse Products', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
