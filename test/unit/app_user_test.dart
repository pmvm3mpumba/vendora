import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendora/features/auth/models/app_user.dart';

void main() {
  test('Un document vendeur devient un modèle typé', () {
    final user = AppUser.fromMap('uid-test', {
      'name': 'Vendeur Test',
      'email': 'vendeur@example.com',
      'phone': '+25779123456',
      'role': 'seller',
      'whatsappNumber': '+25779123456',
      'createdAt': Timestamp.fromDate(DateTime.utc(2026, 1, 1)),
    });
    expect(user.id, 'uid-test');
    expect(user.isSeller, isTrue);
    expect(user.role.label, 'Vendeur');
  });

  test('Un rôle inconnu est refusé', () {
    expect(() => UserRole.parse('admin'), throwsFormatException);
  });

  test('Une date serveur encore en attente est acceptée', () {
    final user = AppUser.fromMap('uid-test', {
      'name': 'Client Test',
      'email': 'client@example.com',
      'phone': '+25779123456',
      'role': 'client',
      'whatsappNumber': '',
      'createdAt': null,
    });
    expect(user.createdAt, isNull);
    expect(user.isSeller, isFalse);
  });
}
