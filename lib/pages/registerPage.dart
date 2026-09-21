import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  bool loading = false;

  static const _primaryOrange = Color(0xFFFF6F2C);
  static const _oceanUrl =
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=900&q=80';

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showComingSoon(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fitur register dengan $provider belum tersedia (hanya tampilan).')),
    );
  }

  Future<void> createAccount() async {
    final name = nameController.text;
    final email = emailController.text.trim();
    final password = passwordController.text;
    setState(() => loading = true);
    final error = AuthService.instance.register(name: name, email: email, password: password);
    if (!mounted) return;
    setState(() => loading = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Akun berhasil dibuat. Silakan login.')));
    context.go('/login?email=${Uri.encodeComponent(email)}');
  }

  Widget _socialButton({required Widget child, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              _oceanUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, e, s) => Container(color: const Color(0xFF7AB8D6)),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.10),
                    Colors.black.withValues(alpha: 0.00),
                    Colors.black.withValues(alpha: 0.18),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    'assets/images/carhatt.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, e, s) => Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, e, s) => const Icon(Icons.shopping_bag, color: Color(0xFFFF6F2C)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 24, offset: Offset(0, -4))],
                ),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('New', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black, height: 1.1)),
                              Text('Account', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black, height: 1.1)),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            InkWell(
                              onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload picture belum tersedia (hanya tampilan).'))),
                              borderRadius: BorderRadius.circular(22),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFFFB89A), width: 1.4),
                                  color: Colors.white,
                                ),
                                child: const Icon(Icons.camera_alt_outlined, size: 20, color: Color(0xFFFF6F2C)),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Upload picture', style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey.shade500)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Text('Email', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Talice@163.com',
                        hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
                        prefixIcon: Icon(Icons.email_outlined, size: 18, color: Colors.grey.shade600),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _primaryOrange, width: 1.4)),
                        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('Username', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Alice',
                        hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
                        prefixIcon: Icon(Icons.person_outline, size: 18, color: Colors.grey.shade600),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _primaryOrange, width: 1.4)),
                        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('Password', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => createAccount(),
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 2),
                      decoration: InputDecoration(
                        hintText: '••••••',
                        hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400, letterSpacing: 2),
                        prefixIcon: Icon(Icons.lock_outline, size: 18, color: Colors.grey.shade600),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => obscurePassword = !obscurePassword),
                          icon: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: Colors.grey.shade600),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _primaryOrange, width: 1.4)),
                        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: loading ? null : createAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryOrange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                        ),
                        child: loading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                            : Text('Sign up', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(child: Text('or sign up with', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500))),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _socialButton(
                          onTap: () => _showComingSoon('Google'),
                          child: Text('G', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF4285F4))),
                        ),
                        const SizedBox(width: 16),
                        _socialButton(
                          onTap: () => _showComingSoon('Facebook'),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(color: const Color(0xFF1877F2), borderRadius: BorderRadius.circular(4)),
                            child: Center(child: Text('f', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, height: 1))),
                          ),
                        ),
                        const SizedBox(width: 16),
                        _socialButton(
                          onTap: () => _showComingSoon('X'),
                          child: const Icon(Icons.close, size: 18, color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account? ', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text('Sign in', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: _primaryOrange)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
