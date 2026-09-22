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

/// Checkout — premium minimal, whitespace-driven.
/// Logic 100% sama: cartProvider, validasi alamat, paymentMethod, placeOrder.
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
  static const _bg = Color(0xFFF8F8F6);
  static const _textPrimary = Color(0xFF111111);
  static const _textSecondary = Color(0xFF8A8A8A);
  static const _hairline = Color(0xFFEDEDE9);

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih metode pembayaran.')));
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
      SnackBar(content: Text('Pesanan ${order.id} berhasil! Total ${Product.priceTextStatic(total)} via ${order.paymentMethod}.')),
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
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShippingAddress(),
            const SizedBox(height: 28),
            _buildOrderSummary(cart: cart, totalQty: totalQty),
            const SizedBox(height: 28),
            _buildPriceDetails(subtotal: subtotal, shipping: shipping, total: total),
            const SizedBox(height: 28),
            _buildPaymentMethod(),
            const SizedBox(height: 12),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(total: total, cart: cart, subtotal: subtotal, shipping: shipping),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: () => context.canPop() ? context.pop() : context.go('/cart'),
        icon: const Icon(Icons.arrow_back, color: _textPrimary, size: 20),
      ),
      centerTitle: true,
      title: Text('Checkout', style: GoogleFonts.poppins(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildShippingAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Shipping Address', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary)),
        const SizedBox(height: 16),
        _MinimalField(controller: nameController, hint: 'Nama penerima', icon: Icons.person_outline, textInputAction: TextInputAction.next),
        const SizedBox(height: 14),
        _MinimalField(controller: phoneController, hint: 'Nomor telepon', icon: Icons.phone_outlined, keyboardType: TextInputType.phone, textInputAction: TextInputAction.next),
        const SizedBox(height: 14),
        _MinimalField(controller: addressController, hint: 'Alamat lengkap', icon: Icons.location_on_outlined, maxLines: 2, textInputAction: TextInputAction.next),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _MinimalField(controller: cityController, hint: 'Kota', icon: Icons.location_city_outlined, textInputAction: TextInputAction.next)),
            const SizedBox(width: 16),
            Expanded(child: _MinimalField(controller: zipController, hint: 'Kode pos', icon: Icons.local_post_office_outlined, keyboardType: TextInputType.number, textInputAction: TextInputAction.done)),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderSummary({required List<CartItem> cart, required int totalQty}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Order Summary', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary)),
            const SizedBox(width: 6),
            Text('·  $totalQty item', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400, color: _textSecondary)),
          ],
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < cart.length; i++) ...[
          _ProductRow(item: cart[i]),
          if (i != cart.length - 1) Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1, thickness: 0.7, color: _hairline)),
        ],
      ],
    );
  }

  Widget _buildPriceDetails({required int subtotal, required int shipping, required int total}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Price Details', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary)),
        const SizedBox(height: 16),
        _PriceRow(label: 'Subtotal', value: Product.priceTextStatic(subtotal)),
        const SizedBox(height: 10),
        _PriceRow(label: 'Shipping', value: Product.priceTextStatic(shipping)),
        const SizedBox(height: 14),
        Divider(height: 1, thickness: 0.7, color: _hairline),
        const SizedBox(height: 14),
        Row(
          children: [
            Text('Total', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary)),
            const Spacer(),
            Text(Product.priceTextStatic(total), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: _textPrimary)),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Method', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary)),
        const SizedBox(height: 14),
        for (final method in availablePaymentMethods) ...[
          _PaymentRow(
            method: method,
            isSelected: method == selectedPaymentMethod,
            onTap: () => _handleSelectPaymentMethod(method),
          ),
          if (method != availablePaymentMethods.last) const SizedBox(height: 2),
        ],
      ],
    );
  }

  Widget _buildBottomBar({required int total, required List<CartItem> cart, required int subtotal, required int shipping}) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: _hairline, width: 0.8)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w400, color: _textSecondary, letterSpacing: 0.3)),
                  const SizedBox(height: 2),
                  Text(Product.priceTextStatic(total), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: _textPrimary)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 26),
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

class _MinimalField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  const _MinimalField({required this.controller, required this.hint, required this.icon, this.keyboardType, this.textInputAction, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400, color: const Color(0xFF111111), height: 1.4),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFFB0B0B0), fontWeight: FontWeight.w400),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF9A9A9A)),
        prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: maxLines > 1 ? 12 : 13),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE6E6E2), width: 0.9)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFC72C), width: 1.1)),
        border: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE6E6E2))),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final CartItem item;
  const _ProductRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Container(
            color: const Color(0xFFF1F1EF),
            child: Image.network(
              product.image,
              width: 66,
              height: 66,
              fit: BoxFit.cover,
              errorBuilder: (_, e, s) => const SizedBox(width: 66, height: 66, child: Icon(Icons.image_outlined, size: 18, color: Color(0xFFB0B0B0))),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF111111), height: 1.35)),
              const SizedBox(height: 4),
              Text('Size ${item.size}  ·  Qty ${item.quantity}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF8A8A8A))),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(item.subtotalText, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF111111))),
        ),
      ],
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
        Text(label, style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF8A8A8A))),
        const Spacer(),
        Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF111111))),
      ],
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String method;
  final bool isSelected;
  final VoidCallback onTap;
  const _PaymentRow({required this.method, required this.isSelected, required this.onTap});

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

  String _label(String m) => m == 'CASH' ? 'Cash' : m;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFC72C).withValues(alpha: 0.13) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(_icon(method), size: 18, color: const Color(0xFF2B2B2B)),
            const SizedBox(width: 12),
            Expanded(child: Text(_label(method), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF111111)))),
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, size: 18, color: isSelected ? const Color(0xFF111111) : const Color(0xFFB8B8B5)),
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
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 40, color: Color(0xFFB8B8B5)),
            const SizedBox(height: 14),
            Text('Cart is empty', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF111111))),
            const SizedBox(height: 6),
            Text('Add products to checkout', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF8A8A8A))),
            const SizedBox(height: 20),
            SizedBox(
              height: 46,
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
