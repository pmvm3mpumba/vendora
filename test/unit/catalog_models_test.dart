import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendora/core/models/app_currency.dart';
import 'package:vendora/features/catalog/data/category_repository.dart';
import 'package:vendora/features/catalog/models/category.dart';
import 'package:vendora/features/catalog/models/product.dart';

Map<String, dynamic> categoryData() => {
  'name': 'Tech',
  'description': 'Les essentiels connectés.',
  'iconKey': 'tech',
  'sortOrder': 1,
  'isActive': true,
};

Map<String, dynamic> productData() => {
  'name': 'Produit de test',
  'description': 'Description de test.',
  'priceMinor': 135000,
  'currency': 'BIF',
  'categoryId': 'tech',
  'stock': 12,
  'imageUrl': 'https://example.com/product.jpg',
  'imagePath': null,
  'sellerId': 'seller-test',
  'sellerName': 'Vendeur Test',
  'sellerWhatsappNumber': '+25779123456',
  'isActive': true,
  'createdAt': Timestamp.fromDate(DateTime.utc(2026, 1, 1)),
  'updatedAt': Timestamp.fromDate(DateTime.utc(2026, 1, 1)),
};

void main() {
  group('Catégories', () {
    test('Lit un document valide', () {
      final category = Category.fromMap('tech', categoryData());
      expect(category.name, 'Tech');
      expect(category.isActive, isTrue);
      expect(category.sortOrder, 1);
    });
    test('Description et icône sont facultatives', () {
      final data = categoryData()
        ..remove('description')
        ..remove('iconKey');
      final category = Category.fromMap('tech', data);
      expect(category.description, '');
      expect(category.iconKey, 'category');
    });
    test('Refuse un nom vide', () {
      expect(
        () => Category.fromMap('tech', categoryData()..['name'] = ' '),
        throwsFormatException,
      );
    });
    test('Refuse un booléen stocké comme texte', () {
      expect(
        () => Category.fromMap('tech', categoryData()..['isActive'] = 'true'),
        throwsFormatException,
      );
    });
    test('Refuse un ordre décimal ou négatif', () {
      for (final value in [1.5, -1]) {
        expect(
          () => Category.fromMap('tech', categoryData()..['sortOrder'] = value),
          throwsFormatException,
        );
      }
    });
    test('Trie et exclut les inactives sans modifier la liste source', () {
      final tech = Category.fromMap('tech', categoryData()..['sortOrder'] = 2);
      final fashion = Category.fromMap(
        'mode',
        categoryData()..['name'] = 'Mode',
      );
      final hidden = Category.fromMap(
        'hidden',
        categoryData()..['isActive'] = false,
      );
      final input = [tech, hidden, fashion];
      final sorted = sortCategories(input);
      expect(sorted.map((c) => c.id), ['mode', 'tech']);
      expect(input.length, 3);
      expect(() => sorted.clear(), throwsUnsupportedError);
    });
    test('Départage un ordre identique par nom', () {
      final a = Category.fromMap('a', categoryData()..['name'] = 'Accessoires');
      final t = Category.fromMap('t', categoryData());
      expect(sortCategories([t, a]).first.id, 'a');
    });
  });

  group('Produits : contrat de données', () {
    test('Lit les champs obligatoires et les dates', () {
      final product = Product.fromMap('p1', productData());
      expect(product.priceMinor, 135000);
      expect(product.currency, AppCurrency.bif);
      expect(product.priceForDisplay, 135000);
      expect(product.isInStock, isTrue);
      expect(product.createdAt, DateTime.utc(2026, 1, 1));
    });
    test('USD et EUR sont stockés en centimes', () {
      for (final code in ['USD', 'EUR']) {
        final product = Product.fromMap(
          'p1',
          productData()
            ..['priceMinor'] = 1299
            ..['currency'] = code,
        );
        expect(product.priceForDisplay, 12.99);
      }
    });
    test('Refuse un prix nul, négatif ou décimal', () {
      for (final value in [0, -50, 12.99]) {
        expect(
          () => Product.fromMap('p1', productData()..['priceMinor'] = value),
          throwsFormatException,
        );
      }
    });
    test('Refuse un stock négatif ou fractionnaire', () {
      for (final value in [-1, 1.5]) {
        expect(
          () => Product.fromMap('p1', productData()..['stock'] = value),
          throwsFormatException,
        );
      }
    });
    test('Un produit épuisé ou inactif n’est pas commandable', () {
      expect(
        Product.fromMap('p1', productData()..['stock'] = 0).isInStock,
        isFalse,
      );
      expect(
        Product.fromMap('p1', productData()..['isActive'] = false).isInStock,
        isFalse,
      );
    });
    test('Refuse une devise non prise en charge', () {
      expect(
        () => Product.fromMap('p1', productData()..['currency'] = 'GBP'),
        throwsFormatException,
      );
    });
    test('Refuse les chemins locaux et URL temporaires de navigateur', () {
      for (final value in [
        '/tmp/image.jpg',
        'file:///image.jpg',
        'blob:https://example.com/id',
        'http://example.com/a.jpg',
      ]) {
        expect(
          () => Product.fromMap('p1', productData()..['imageUrl'] = value),
          throwsFormatException,
        );
      }
    });
    test('Refuse un numéro WhatsApp non international', () {
      expect(
        () => Product.fromMap(
          'p1',
          productData()..['sellerWhatsappNumber'] = '79123456',
        ),
        throwsFormatException,
      );
    });
    test('Accepte une date serveur encore en attente', () {
      expect(
        Product.fromMap('p1', productData()..['createdAt'] = null).createdAt,
        isNull,
      );
    });
    test('Refuse une date de mauvais type', () {
      expect(
        () => Product.fromMap('p1', productData()..['createdAt'] = 'hier'),
        throwsFormatException,
      );
    });
    test('Refuse un champ obligatoire absent', () {
      expect(
        () => Product.fromMap('p1', productData()..remove('sellerId')),
        throwsFormatException,
      );
    });
  });
}
