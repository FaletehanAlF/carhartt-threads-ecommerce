import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final String? initialEmail;
  const LoginPage({super.key, this.initialEmail});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController emailController;
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  bool loading = false;
  bool _autoValidate = false;

  static const _primary = Color(0xFFFFC72C);
  static const _primaryDark = Color(0xFFB8860B);

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.initialEmail ?? registeredEmail);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool get _isFormFilled =>
      emailController.text.trim().isNotEmpty && passwordController.text.isNotEmpty;

  String? _validateEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Email wajib diisi';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)) return 'Format email tidak valid';
    return null;
  }

  String? _validatePassword(String? v) {
    if ((v ?? '').isEmpty) return 'Password wajib diisi';
    if ((v ?? '').length < 6) return 'Minimal 6 karakter';
    return null;
  }

  Future<void> login() async {
    setState(() => _autoValidate = true);
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    final email = emailController.text.trim();
    final password = passwordController.text;
    setState(() => loading = true);
    final error = AuthService.instance.login(email: email, password: password);
    if (!mounted) return;
    setState(() => loading = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (mounted) context.go('/home');
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
      backgroundColor: const Color(0xFFF9F9F8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                      const SizedBox(height: 12),
                      // Brand
                      Center(
                        child: Image.asset(
                          'assets/images/carhatt.png',
                          height: 110,
                          fit: BoxFit.contain,
                          errorBuilder: (_, e, s) => Image.asset(
                            'assets/images/logo.png',
                            height: 110,
                            fit: BoxFit.contain,
                            errorBuilder: (_, e, s) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(10)),
                                  child: const Icon(Icons.shopping_bag, size: 24, color: Colors.black),
                                ),
                                const SizedBox(width: 10),
                                Text('carhartt', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Welcome back', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.black, height: 1.15)),
                      const SizedBox(height: 8),
                      Text('Sign in to continue shopping', style: GoogleFonts.inter(fontSize: 14.5, color: Colors.grey.shade600, height: 1.4)),
                      const SizedBox(height: 32),
                      // Email
                      Text('Email', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.black87)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: _validateEmail,
                        onChanged: (_) => setState(() {}),
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                        decoration: _dec(hint: 'you@example.com', icon: Icons.mail_outlined),
                      ),
                      const SizedBox(height: 18),
                      // Password
                      Text('Password', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.black87)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        validator: _validatePassword,
                        onChanged: (_) => setState(() {}),
                        onFieldSubmitted: (_) => login(),
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                        decoration: _dec(
                          hint: 'Enter your password',
                          icon: Icons.lock_outline,
                          suffix: IconButton(
                            onPressed: () => setState(() => obscurePassword = !obscurePassword),
                            icon: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: Colors.grey.shade600),
                            tooltip: obscurePassword ? 'Show password' : 'Hide password',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur lupa password belum tersedia'))),
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4), minimumSize: const Size(0, 32), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          child: Text('Forgot password?', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: _primaryDark)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // CTA
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: loading || !_isFormFilled ? null : login,
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
                              : Text('Sign In', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ", style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade700)),
                          GestureDetector(
                            onTap: () => context.push('/register'),
                            child: Text('Create one', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _primaryDark)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
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
