import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

abstract interface class ProductSource {
  Stream<List<Product>> watchActive();
}

class ProductRepository implements ProductSource {
  ProductRepository(this._firestore);
  final FirebaseFirestore _firestore;

  Stream<List<Product>> watchOwned(String sellerId) {
    return _firestore
        .collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
          final products = snapshot.docs
              .map((document) => Product.fromMap(document.id, document.data()))
              .toList();
          products.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
          return List<Product>.unmodifiable(products);
        });
  }

  @override
  Stream<List<Product>> watchActive() {
    return _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final products = snapshot.docs
              .map((document) => Product.fromMap(document.id, document.data()))
              .toList();
          products.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
          return List<Product>.unmodifiable(products);
        });
  }
}
