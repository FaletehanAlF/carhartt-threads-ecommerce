import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import '../services/favorites.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const _bg = Color(0xFFF8F8F6);
  static const _textPrimary = Color(0xFF111111);
  static const _textSecondary = Color(0xFF8A8A8A);
  static const _hairline = Color(0xFFEDEDE9);
  static const _primary = Color(0xFFFFC72C);

  @override
  Widget build(BuildContext context) {
    final String name = AuthService.instance.currentName ?? registeredName;
    final String email = AuthService.instance.currentEmail ?? registeredEmail;
    final String displayName = name.isEmpty ? 'User' : name;
    final String displayEmail = email.isEmpty ? 'No email' : email;
    final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text('Profile', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(initial: initial, displayName: displayName, displayEmail: displayEmail),
            const SizedBox(height: 28),
            _buildAccountInfo(displayName: displayName, displayEmail: displayEmail),
            const SizedBox(height: 28),
            _buildMenu(context),
            const SizedBox(height: 28),
            _buildLogout(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({required String initial, required String displayName, required String displayEmail}) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(color: _primary, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(initial, style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.black)),
          ),
          const SizedBox(height: 14),
          Text(displayName, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: _textPrimary, height: 1.2)),
          const SizedBox(height: 4),
          Text(displayEmail, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400, color: _textSecondary)),
        ],
      ),
    );
  }

  Widget _buildAccountInfo({required String displayName, required String displayEmail}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Account', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: _textSecondary, letterSpacing: 0.8)),
        const SizedBox(height: 14),
        _InfoRow(label: 'Name', value: displayName),
        const SizedBox(height: 16),
        _InfoRow(label: 'Email', value: displayEmail),
        const SizedBox(height: 16),
        ValueListenableBuilder<Set<int>>(
          valueListenable: favoriteProductIds,
          builder: (context, favs, _) {
            return _InfoRow(label: 'Favorites', value: '${favs.length} products');
          },
        ),
      ],
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Column(
      children: [
        _MenuRow(icon: Icons.receipt_long_outlined, label: 'My Orders', onTap: () => context.push('/orders')),
        Divider(height: 1, thickness: 0.7, color: _hairline),
        _MenuRow(icon: Icons.favorite_border, label: 'My Favorites', onTap: () => context.push('/favorites')),
        Divider(height: 1, thickness: 0.7, color: _hairline),
        _MenuRow(icon: Icons.settings_outlined, label: 'Settings', onTap: () => context.push('/settings')),
      ],
    );
  }

  Widget _buildLogout(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () {
          AuthService.instance.logout();
          context.go('/login');
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: _textPrimary,
          side: const BorderSide(color: Color(0xFFE2E2E0), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.white,
        ),
        child: Text('Logout', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: _textPrimary)),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF8A8A8A), letterSpacing: 0.2)),
        const SizedBox(height: 3),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF111111))),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuRow({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF2B2B2B)),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF111111)))),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFB8B8B5)),
          ],
        ),
      ),
    );
  }
}
