import '../../../core/models/app_currency.dart';
import '../../../core/utils/firestore_values.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.priceMinor,
    required this.currency,
    required this.categoryId,
    required this.stock,
    required this.imageUrl,
    required this.sellerId,
    required this.sellerName,
    required this.sellerWhatsappNumber,
    required this.isActive,
    this.localImagePath,
    this.imagePath,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final int priceMinor;
  final AppCurrency currency;
  final String categoryId;
  final int stock;
  final String imageUrl;
  final String? localImagePath;
  final String? imagePath;
  final String sellerId;
  final String sellerName;
  final String sellerWhatsappNumber;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isInStock => isActive && stock > 0;
  double get priceForDisplay => priceMinor / currency.minorUnitFactor;

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    if (id.trim().isEmpty) {
      throw const FormatException('Identifiant de produit manquant.');
    }
    final imageUrlValue = data['imageUrl'];
    if (imageUrlValue is! String) {
      throw const FormatException('Champ imageUrl invalide.');
    }
    final imageUrl = imageUrlValue.trim();
    final localImageValue = data['localImagePath'];
    final localImagePath =
        localImageValue is String && localImageValue.trim().isNotEmpty
        ? localImageValue.trim()
        : null;
    final uri = Uri.tryParse(imageUrl);
    final validRemoteUrl =
        imageUrl.isNotEmpty &&
        uri != null &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty;
    if (!validRemoteUrl && localImagePath == null) {
      throw const FormatException('Une image HTTPS ou locale est nécessaire.');
    }
    final imagePath = data['imagePath'];
    if (imagePath != null &&
        (imagePath is! String ||
            imagePath.trim().isEmpty ||
            imagePath.length > 1024)) {
      throw const FormatException('Chemin Storage invalide.');
    }
    final whatsapp = FirestoreValues.text(
      data,
      'sellerWhatsappNumber',
      maxLength: 16,
    );
    if (!RegExp(r'^\+[1-9][0-9]{7,14}$').hasMatch(whatsapp)) {
      throw const FormatException('Numéro WhatsApp vendeur invalide.');
    }
    final categoryId = FirestoreValues.text(data, 'categoryId', maxLength: 80);
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(categoryId)) {
      throw const FormatException('Identifiant de catégorie invalide.');
    }
    return Product(
      id: id,
      name: FirestoreValues.text(data, 'name', minLength: 2, maxLength: 120),
      description: FirestoreValues.text(
        data,
        'description',
        minLength: 1,
        maxLength: 3000,
      ),
      priceMinor: FirestoreValues.integer(
        data,
        'priceMinor',
        minimum: 1,
        maximum: 1000000000000,
      ),
      currency: AppCurrency.fromCode(
        FirestoreValues.text(data, 'currency', maxLength: 3),
      ),
      categoryId: categoryId,
      stock: FirestoreValues.integer(data, 'stock'),
      imageUrl: imageUrl,
      localImagePath: localImagePath,
      imagePath: imagePath as String?,
      sellerId: FirestoreValues.text(data, 'sellerId', maxLength: 128),
      sellerName: FirestoreValues.text(
        data,
        'sellerName',
        minLength: 2,
        maxLength: 80,
      ),
      sellerWhatsappNumber: whatsapp,
      isActive: FirestoreValues.boolean(data, 'isActive'),
      createdAt: FirestoreValues.timestamp(data, 'createdAt'),
      updatedAt: FirestoreValues.timestamp(data, 'updatedAt'),
    );
  }
}
