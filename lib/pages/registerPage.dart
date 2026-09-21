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
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool loading = false;
  bool _autoValidate = false;

  static const _primary = Color(0xFFFFC72C);
  static const _primaryDark = Color(0xFFB8860B);

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  bool get _isFormFilled =>
      nameController.text.trim().isNotEmpty &&
      emailController.text.trim().isNotEmpty &&
      passwordController.text.isNotEmpty &&
      confirmController.text.isNotEmpty;

  String? _vName(String? v) {
    if ((v ?? '').trim().isEmpty) return 'Nama wajib diisi';
    if ((v ?? '').trim().length < 2) return 'Nama terlalu pendek';
    return null;
  }

  String? _vEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Email wajib diisi';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)) return 'Format email tidak valid';
    return null;
  }

  String? _vPass(String? v) {
    if ((v ?? '').isEmpty) return 'Password wajib diisi';
    if ((v ?? '').length < 6) return 'Minimal 6 karakter';
    return null;
  }

  String? _vConfirm(String? v) {
    if ((v ?? '').isEmpty) return 'Konfirmasi password wajib diisi';
    if (v != passwordController.text) return 'Password tidak sama';
    return null;
  }

  Future<void> createAccount() async {
    setState(() => _autoValidate = true);
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    final name = nameController.text.trim();
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

  InputDecoration _dec({required String hint, required IconData icon, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400),
      prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade600),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primary, width: 1.6)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE53935))),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.4)),
      errorStyle: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFE53935)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                builder: (context, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 8 * (1 - v)), child: child)),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/carhatt.png',
                          width: 280,
                          height: 280,
                          fit: BoxFit.contain,
                          errorBuilder: (_, e, s) => Image.asset(
                            'assets/images/logo.png',
                            width: 280,
                            height: 280,
                            fit: BoxFit.contain,
                            errorBuilder: (_, e, s) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(width: 56, height: 56, decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.shopping_bag, size: 28, color: Colors.black)),
                                const SizedBox(width: 10),
                                Text('carhartt', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text('Create your account', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.black, height: 1.15)),
                      const SizedBox(height: 8),
                      Text('Start your shopping journey with us', style: GoogleFonts.inter(fontSize: 14.5, color: Colors.grey.shade600, height: 1.4)),
                      const SizedBox(height: 28),
                      Text('Full Name', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.black87)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: nameController,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        validator: _vName,
                        onChanged: (_) => setState(() {}),
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                        decoration: _dec(hint: 'Your full name', icon: Icons.person_outline),
                      ),
                      const SizedBox(height: 16),
                      Text('Email', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.black87)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: _vEmail,
                        onChanged: (_) => setState(() {}),
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                        decoration: _dec(hint: 'you@example.com', icon: Icons.mail_outlined),
                      ),
                      const SizedBox(height: 16),
                      Text('Password', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.black87)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        validator: _vPass,
                        onChanged: (_) => setState(() {}),
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                        decoration: _dec(
                          hint: 'At least 6 characters',
                          icon: Icons.lock_outline,
                          suffix: IconButton(
                            onPressed: () => setState(() => obscurePassword = !obscurePassword),
                            icon: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: Colors.grey.shade600),
                            tooltip: obscurePassword ? 'Show password' : 'Hide password',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Confirm Password', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.black87)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: confirmController,
                        obscureText: obscureConfirm,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        validator: _vConfirm,
                        onChanged: (_) => setState(() {}),
                        onFieldSubmitted: (_) => createAccount(),
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                        decoration: _dec(
                          hint: 'Repeat your password',
                          icon: Icons.lock_outline,
                          suffix: IconButton(
                            onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                            icon: Icon(obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: Colors.grey.shade600),
                            tooltip: obscureConfirm ? 'Show password' : 'Hide password',
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: loading || !_isFormFilled ? null : createAccount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.black,
                            disabledBackgroundColor: const Color(0xFFEDEDE9),
                            disabledForegroundColor: Colors.grey.shade600,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: loading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.black))
                              : Text('Create Account', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account? ', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade700)),
                          GestureDetector(onTap: () => context.go('/login'), child: Text('Sign in', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _primaryDark))),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
