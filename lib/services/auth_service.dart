/// Session auth sederhana (in-memory).
///
/// Menyimpan akun yang didaftarkan lewat [AuthService.register]
/// dan sesi login aktif. Variabel global [registeredName],
/// [registeredEmail], [registeredPassword] dipertahankan agar
/// file lama yang mengimpornya tetap jalan.
import 'package:flutter/foundation.dart';

String registeredName = '';
String registeredEmail = '';
String registeredPassword = '';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final Map<String, _User> _usersByEmail = {};
  _User? _currentUser;

  /// Didengarkan oleh GoRouter (refreshListenable) agar redirect
  /// auth (login/logout) berjalan otomatis tanpa bug.
  final ValueNotifier<bool> authNotifier = ValueNotifier<bool>(false);

  String? get currentName => _currentUser?.name;
  String? get currentEmail => _currentUser?.email;

  bool get isLoggedIn => _currentUser != null;

  /// Daftarkan akun baru. Return null jika sukses,
  /// atau pesan error jika validasi gagal.
  String? register({
    required String name,
    required String email,
    required String password,
  }) {
    final n = name.trim();
    final e = email.trim();
    final p = password;

    if (n.isEmpty) return 'Nama tidak boleh kosong.';
    if (e.isEmpty) return 'Email tidak boleh kosong.';
    if (!_isValidEmail(e)) return 'Format email tidak valid.';
    if (p.isEmpty) return 'Password tidak boleh kosong.';
    if (p.length < 6) return 'Password minimal 6 karakter.';

    final key = e.toLowerCase();
    if (_usersByEmail.containsKey(key)) {
      return 'Email sudah terdaftar. Silakan login.';
    }

    _usersByEmail[key] = _User(name: n, email: e, password: p);

    // Sinkronkan global lama agar profile/login lama tetap jalan.
    registeredName = n;
    registeredEmail = e;
    registeredPassword = p;
    return null;
  }

  /// Login. Return null jika sukses, atau pesan error.
  String? login({required String email, required String password}) {
    final e = email.trim();
    final p = password;

    if (e.isEmpty || p.isEmpty) {
      return 'Email dan password wajib diisi.';
    }
    final user = _usersByEmail[e.toLowerCase()];
    if (user == null) {
      return 'Akun belum terdaftar. Silakan buat akun dulu.';
    }
    if (user.password != p) {
      return 'Email atau password tidak sesuai.';
    }
    _currentUser = user;

    registeredName = user.name;
    registeredEmail = user.email;
    registeredPassword = user.password;
    authNotifier.value = true;
    return null;
  }

  void logout() {
    _currentUser = null;
    authNotifier.value = false;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }
}

class _User {
  final String name;
  final String email;
  final String password;

  _User({required this.name, required this.email, required this.password});
}
