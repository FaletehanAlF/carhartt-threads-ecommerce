import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';

/// Ongkos kirim flat sementara (tahap awal).
const int flatShippingCost = 10000;

/// Halaman Checkout — data produk 100% dari [cartProvider] (Riverpod).
///
/// - Baca state: `ref.watch(cartProvider)` / `ref.watch(cartTotalPriceProvider)`
/// - Tidak ada data dummy.
/// - Form alamat + metode pembayaran hanya local state tahap pertama.
/// - Pesanan dibuat dengan status "Berhasil" dan metode pembayaran pilihan user.
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

  // Metode pembayaran yang dipilih user. Default DANA.
  String selectedPaymentMethod = availablePaymentMethods.first;

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
    // Validasi alamat.
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        zipController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi alamat pengiriman terlebih dahulu.'),
        ),
      );
      return;
    }
    if (cart.isEmpty) return;

    // Validasi metode pembayaran sudah dipilih (selalu ada default).
    if (!availablePaymentMethods.contains(selectedPaymentMethod)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih metode pembayaran.')),
      );
      return;
    }

    // Buat pesanan dengan status "Berhasil" + metode pembayaran pilihan user.
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
        content: Text(
          'Pesanan ${order.id} berhasil! '
          'Total ${Product.priceTextStatic(total)} via ${order.paymentMethod}.',
        ),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/cart');
            }
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          'Checkout',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: cart.isEmpty
          ? _EmptyCheckout(onBack: () => context.go('/cart'))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(title: 'Produk ($totalQty item)'),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cart.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _CheckoutItemTile(item: cart[index]);
                    },
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Alamat Pengiriman'),
                  const SizedBox(height: 12),
                  _AddressForm(
                    nameController: nameController,
                    phoneController: phoneController,
                    addressController: addressController,
                    cityController: cityController,
                    zipController: zipController,
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Metode Pembayaran'),
                  const SizedBox(height: 12),
                  _PaymentMethodSelector(
                    selectedMethod: selectedPaymentMethod,
                    onSelect: _handleSelectPaymentMethod,
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Ringkasan Pembayaran'),
                  const SizedBox(height: 12),
                  _PaymentSummary(
                    subtotal: subtotal,
                    shipping: shipping,
                    total: total,
                    paymentMethod: selectedPaymentMethod,
                  ),
                  const SizedBox(height: 20),
                  SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () => _payNow(
                          cart: cart,
                          subtotal: subtotal,
                          shipping: shipping,
                          total: total,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC72C),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Bayar Sekarang',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold),
    );
  }
}

class _CheckoutItemTile extends StatelessWidget {
  final CartItem item;

  const _CheckoutItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              product.image,
              width: 72,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 72,
                  height: 80,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_outlined, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Size ${item.size} • ${item.quantity} x ${product.priceText}',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    item.subtotalText,
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController zipController;

  const _AddressForm({
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.cityController,
    required this.zipController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _AddressField(
            controller: nameController,
            hint: 'Nama penerima',
            icon: Icons.person_outline,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          _AddressField(
            controller: phoneController,
            hint: 'Nomor telepon',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          _AddressField(
            controller: addressController,
            hint: 'Alamat lengkap (jalan, RT/RW, patokan)',
            icon: Icons.home_outlined,
            maxLines: 2,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _AddressField(
                  controller: cityController,
                  hint: 'Kota',
                  icon: Icons.location_city_outlined,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AddressField(
                  controller: zipController,
                  hint: 'Kode pos',
                  icon: Icons.markunread_mailbox_outlined,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                ),
              ),
            ],
          ),
        ],
      ),
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

  const _AddressField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}

/// Selector metode pembayaran DANA, GOPAY, OVO, CASH.
/// Dipisah agar mudah dibaca pemula: satu widget satu tanggung jawab.
class _PaymentMethodSelector extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String> onSelect;

  const _PaymentMethodSelector({
    required this.selectedMethod,
    required this.onSelect,
  });

  IconData _iconForMethod(String method) {
    switch (method) {
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

  String _labelForMethod(String method) {
    switch (method) {
      case 'DANA':
        return 'DANA';
      case 'GOPAY':
        return 'GoPay';
      case 'OVO':
        return 'OVO';
      case 'CASH':
        return 'Cash (COD)';
      default:
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (final method in availablePaymentMethods) ...[
            _PaymentMethodTile(
              method: method,
              label: _labelForMethod(method),
              icon: _iconForMethod(method),
              isSelected: method == selectedMethod,
              onTap: () => onSelect(method),
            ),
            if (method != availablePaymentMethods.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final String method;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.method,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFC72C).withValues(alpha: 0.18) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFC72C) : Colors.grey.shade300,
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: Colors.black87),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFFB8860B) : Colors.grey.shade400,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentSummary extends StatelessWidget {
  final int subtotal;
  final int shipping;
  final int total;
  final String paymentMethod;

  const _PaymentSummary({
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal produk', value: Product.priceTextStatic(subtotal)),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Ongkos kirim', value: Product.priceTextStatic(shipping)),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Metode bayar', value: paymentMethod),
          const Divider(height: 24),
          _SummaryRow(label: 'Total pembayaran', value: Product.priceTextStatic(total), isTotal: true),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 16 : 13,
            fontWeight: FontWeight.bold,
            color: isTotal ? const Color(0xFFB8860B) : Colors.black,
          ),
        ),
      ],
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(60)),
              alignment: Alignment.center,
              child: const Icon(Icons.receipt_long_outlined, size: 56, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text('Tidak ada produk untuk checkout', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Cart masih kosong. Tambahkan produk dulu sebelum checkout.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: onBack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC72C),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Kembali ke Cart', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
