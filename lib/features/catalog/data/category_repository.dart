import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category.dart';

abstract interface class CategorySource {
  Stream<List<Category>> watchActive();
}

class CategoryRepository implements CategorySource {
  CategoryRepository(this._firestore);
  final FirebaseFirestore _firestore;

  @override
  Stream<List<Category>> watchActive() {
    // Le filtre doit correspondre aux Security Rules : elles ne filtrent pas
    // les résultats à notre place. Pas de lecture de toutes les catégories.
    return _firestore
        .collection('categories')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => sortCategories(
            snapshot.docs.map(
              (document) => Category.fromMap(document.id, document.data()),
            ),
          ),
        );
  }
}

/// Petit référentiel : tri local pour éviter un index composite inutile.
List<Category> sortCategories(Iterable<Category> categories) {
  final result = categories.where((category) => category.isActive).toList();
  result.sort((a, b) {
    final order = a.sortOrder.compareTo(b.sortOrder);
    if (order != 0) return order;
    final name = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    return name != 0 ? name : a.id.compareTo(b.id);
  });
  return List<Category>.unmodifiable(result);
}
