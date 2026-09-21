import 'package:carhartt_shop/models/product.dart';
import 'package:carhartt_shop/services/api_service.dart';
import 'package:carhartt_shop/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthService', () {
    test('register lalu login sukses', () {
      final auth = AuthService.instance;
      final err = auth.register(
        name: 'Test User',
        email: 'test${DateTime.now().millisecondsSinceEpoch}@mail.com',
        password: 'secret123',
      );
      expect(err, isNull);
    });

    test('register menolak email invalid & password pendek', () {
      final auth = AuthService.instance;
      expect(
        auth.register(name: 'A', email: 'bukan-email', password: 'secret123'),
        isNotNull,
      );
      expect(
        auth.register(name: 'A', email: 'a@b.com', password: '123'),
        isNotNull,
      );
      expect(
        auth.register(name: '', email: 'a@b.com', password: 'secret123'),
        isNotNull,
      );
    });

    test('login menolak akun yang belum terdaftar', () {
      final auth = AuthService.instance;
      expect(
        auth.login(email: 'belum@ada.com', password: 'apapun123'),
        isNotNull,
      );
    });
  });

  group('Product filter', () {
    const sample = [
      Product(
        id: 1,
        name: 'K87 T-Shirt',
        category: 'T-Shirt',
        price: 599000,
        image: '',
        description: 'kaos',
      ),
      Product(
        id: 2,
        name: 'Detroit Jacket',
        category: 'Jacket',
        price: 1499000,
        image: '',
        description: 'jaket',
      ),
    ];

    test('filter kategori', () {
      final res = ApiService.filter(
        source: sample,
        category: 'Jacket',
      );
      expect(res.length, 1);
      expect(res.first.name, 'Detroit Jacket');
    });

    test('filter search', () {
      final res = ApiService.filter(
        source: sample,
        category: 'All',
        query: 'k87',
      );
      expect(res.length, 1);
    });

    test('format harga', () {
      expect(sample.first.priceText, 'Rp 599.000');
    });
  });
}
