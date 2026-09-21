import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/order.dart';
import '../models/product.dart';
import '../providers/orders_provider.dart';

/// Halaman Detail Pesanan — dibuka ketika user tap riwayat di OrdersPage.
///
/// Data diambil langsung dari [Order] (snapshot dari Checkout):
/// - Alamat berasal dari form Checkout (receiverName, phone, address, city, zip)
/// - Metode pembayaran berasal dari pilihan DANA/GOPAY/OVO/CASH
/// - Items berasal dari Cart snapshot
/// - Status selalu "Berhasil"
class OrderDetailPage extends ConsumerWidget {
  final Order? order;
  final String? orderId;

  const OrderDetailPage({super.key, this.order, this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Tentukan order yang akan ditampilkan.
    // Priority: order dari extra -> lookup by id dari provider -> null.
    Order? displayedOrder = order;

    if (displayedOrder == null && orderId != null) {
      final List<Order> allOrders = ref.watch(ordersProvider);
      try {
        displayedOrder = allOrders.firstWhere((o) => o.id == orderId);
      } catch (_) {
        displayedOrder = null;
      }
    }

    if (displayedOrder == null) {
      return _buildNotFoundPage(context);
    }

    final Order currentOrder = displayedOrder;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/orders');
            }
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          'Detail Pesanan',
          style: GoogleFonts.poppins(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(order: currentOrder),
            const SizedBox(height: 16),
            _buildAddressCard(order: currentOrder),
            const SizedBox(height: 16),
            _buildPaymentCard(order: currentOrder),
            const SizedBox(height: 16),
            _buildProductsSection(order: currentOrder),
            const SizedBox(height: 16),
            _buildSummaryCard(order: currentOrder),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundPage(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : context.go('/orders'),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text('Pesanan tidak ditemukan', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                'Pesanan dengan ID "$orderId" tidak ditemukan.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/orders'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC72C), foregroundColor: Colors.black, elevation: 0),
                child: Text('Kembali ke Riwayat', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard({required Order order}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(order.id, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              _StatusChip(status: order.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${order.dateText} • ${order.totalQty} item',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard({required Order order}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: const Color(0xFFFFC72C).withValues(alpha: 0.20), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.location_on_outlined, size: 20, color: Colors.black),
              ),
              const SizedBox(width: 12),
              Text('Alamat Pengiriman', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Text(order.receiverName, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(order.phone, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700)),
          const SizedBox(height: 6),
          Text(
            order.fullAddressText,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard({required Order order}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Icon(_iconForPayment(order.paymentMethod), size: 22, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Metode Pembayaran', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 2),
                Text(_labelForPayment(order.paymentMethod), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
            child: Text('Lunas', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32))),
          ),
        ],
      ),
    );
  }

  IconData _iconForPayment(String method) {
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

  String _labelForPayment(String method) {
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

  Widget _buildProductsSection({required Order order}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Produk (${order.totalQty} item)', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              for (int i = 0; i < order.items.length; i++) ...[
                _OrderProductTile(item: order.items[i]),
                if (i != order.items.length - 1) Divider(color: Colors.grey.shade200, height: 20),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({required Order order}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal produk', value: Product.priceTextStatic(order.subtotal)),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Ongkos kirim', value: Product.priceTextStatic(order.shipping)),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Metode', value: order.paymentMethod),
          const Divider(height: 24),
          _SummaryRow(label: 'Total pembayaran', value: Product.priceTextStatic(order.total), isTotal: true),
        ],
      ),
    );
  }
}

class _OrderProductTile extends StatelessWidget {
  final dynamic item;

  const _OrderProductTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            product.image,
            width: 64,
            height: 70,
            fit: BoxFit.cover,
            errorBuilder: (_, e, s) => Container(
              width: 64,
              height: 70,
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
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                'Size ${item.size} • ${item.quantity} x ${product.priceText}',
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(item.subtotalText, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({required this.label, required this.value, this.isTotal = false});

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
            fontSize: isTotal ? 15 : 13,
            fontWeight: FontWeight.bold,
            color: isTotal ? const Color(0xFFB8860B) : Colors.black,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final bool isSuccess = status == orderStatusSuccess;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSuccess ? const Color(0xFFE8F5E9) : const Color(0xFFFFC72C).withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSuccess) const Icon(Icons.check_circle, size: 14, color: Color(0xFF2E7D32)),
          if (isSuccess) const SizedBox(width: 4),
          Text(
            status,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isSuccess ? const Color(0xFF2E7D32) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
