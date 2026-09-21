import 'package:flutter_test/flutter_test.dart';
import 'package:vendora/core/validators/auth_validators.dart';

void main() {
  group('Validation des comptes', () {
    test('Le nom vide ou trop court est refusé', () {
      expect(AuthValidators.name('  '), isNotNull);
      expect(AuthValidators.name('A'), isNotNull);
      expect(AuthValidators.name('Alice Test'), isNull);
    });
    test('Une adresse email valide est nécessaire', () {
      expect(AuthValidators.email('alice'), isNotNull);
      expect(AuthValidators.email('alice@example.com'), isNull);
    });
    test('L’inscription impose au moins 8 caractères', () {
      expect(AuthValidators.password('123'), isNotNull);
      expect(AuthValidators.password('Exemple123!'), isNull);
    });
    test('Le téléphone est normalisé et doit être international', () {
      expect(AuthValidators.normalizePhone('+257 79 12 34 56'), '+25779123456');
      expect(AuthValidators.phone('+257 79 12 34 56'), isNull);
      expect(AuthValidators.phone('79123456'), isNotNull);
      expect(AuthValidators.phone('+00000000'), isNotNull);
    });
  });
}
