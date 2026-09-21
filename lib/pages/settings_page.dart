import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';
import '../services/auth_service.dart';

/// Halaman Settings — preferensi & data lokal (tahap pertama).
///
/// - Riwayat pesanan dibaca/dihapus via [ordersProvider] (Riverpod).
/// - Switch notifikasi hanya local state (belum ada push notification).
/// - Tidak ada backend, tidak ada package baru.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool notificationsEnabled = true;

  Future<void> _confirmClearOrders() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Hapus riwayat pesanan?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Semua riwayat pesanan akan dihapus dari perangkat ini.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Hapus',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed == true && mounted) {
      ref.read(ordersProvider.notifier).clear();
      Fluttertoast.showToast(
        msg: 'Riwayat pesanan dihapus',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Carhartt Shop',
      applicationVersion: '1.0.0+1',
      applicationLegalese: 'Demo e-commerce Flutter (GoRouter + Riverpod).',
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = AuthService.instance.currentName ?? registeredName;
    final email = AuthService.instance.currentEmail ?? registeredEmail;
    final int ordersCount = ref.watch(ordersCountProvider);
    final int cartCount = ref.watch(cartTotalQuantityProvider);

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
              context.go('/home');
            }
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(title: 'Akun'),
            const SizedBox(height: 8),
            _Card(
              child: _RowItem(
                icon: Icons.person_outline,
                title: name.isEmpty ? 'User' : name,
                subtitle: email.isEmpty ? 'No email' : email,
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel(title: 'Pesanan'),
            const SizedBox(height: 8),
            _Card(
              child: Column(
                children: [
                  _RowItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Riwayat Pesanan',
                    subtitle: ordersCount == 0
                        ? 'Belum ada pesanan'
                        : '$ordersCount pesanan',
                    onTap: () => context.push('/orders'),
                  ),
                  const Divider(height: 20),
                  _RowItem(
                    icon: Icons.delete_outline,
                    title: 'Hapus Riwayat Pesanan',
                    iconColor: Colors.red,
                    onTap: ordersCount == 0 ? null : _confirmClearOrders,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel(title: 'Preferensi'),
            const SizedBox(height: 8),
            _Card(
              child: Column(
                children: [
                  Row(
                    children: [
                      _IconBox(icon: Icons.notifications_outlined),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          'Notifikasi',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Switch(
                        value: notificationsEnabled,
                        activeTrackColor: const Color(0xFFFFC72C),
                        onChanged: (v) {
                          // Local state saja (belum ada push notification).
                          setState(() => notificationsEnabled = v);
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  _RowItem(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Kosongkan Cart',
                    subtitle: cartCount == 0
                        ? 'Cart sudah kosong'
                        : '$cartCount item di cart',
                    onTap: cartCount == 0
                        ? null
                        : () {
                            ref.read(cartProvider.notifier).clear();
                            Fluttertoast.showToast(
                              msg: 'Cart dikosongkan',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                          },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel(title: 'Lainnya'),
            const SizedBox(height: 8),
            _Card(
              child: Column(
                children: [
                  _RowItem(
                    icon: Icons.info_outline,
                    title: 'Tentang Aplikasi',
                    subtitle: 'Carhartt Shop 1.0.0+1',
                    onTap: _showAbout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;

  const _IconBox({required this.icon, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFFFFC72C).withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: iconColor ?? Colors.black),
    );
  }
}

class _RowItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _RowItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        _IconBox(icon: icon, iconColor: iconColor),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: onTap == null ? Colors.grey : Colors.black,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ],
    );

    if (onTap == null) return Opacity(opacity: 0.6, child: content);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: content,
    );
  }
}
