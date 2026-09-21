import '../../../core/utils/firestore_values.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.iconKey,
    required this.sortOrder,
    required this.isActive,
  });

  final String id;
  final String name;
  final String description;
  final String iconKey;
  final int sortOrder;
  final bool isActive;

  factory Category.fromMap(String id, Map<String, dynamic> data) {
    if (id.trim().isEmpty) {
      throw const FormatException('Identifiant de catégorie manquant.');
    }
    final description = data['description'];
    final iconKey = data['iconKey'];
    if (description != null &&
        (description is! String || description.length > 240)) {
      throw const FormatException('Description de catégorie invalide.');
    }
    if (iconKey != null && (iconKey is! String || iconKey.length > 40)) {
      throw const FormatException('Icône de catégorie invalide.');
    }
    return Category(
      id: id,
      name: FirestoreValues.text(data, 'name', minLength: 2, maxLength: 60),
      description: (description as String?)?.trim() ?? '',
      iconKey: (iconKey as String?)?.trim() ?? 'category',
      sortOrder: FirestoreValues.integer(data, 'sortOrder', maximum: 10000),
      isActive: FirestoreValues.boolean(data, 'isActive'),
    );
  }
}
