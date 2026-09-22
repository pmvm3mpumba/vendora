/// Résultat d'une image associée à un produit.
/// imageUrl est la valeur persistée dans Firestore.
class StoredProductImage {
  const StoredProductImage({required this.imageUrl, this.imagePath});

  final String imageUrl;
  final String? imagePath;
}

/// Abstraction d'hébergement des images.
///
/// Le formulaire produit dépendra de cette interface, pas d'un fournisseur
/// particulier. L'implémentation pourra être remplacée par Firebase Storage
/// sans réécrire le catalogue ni les commandes.
abstract interface class ProductImageStorage {
  Future<StoredProductImage> saveExternalUrl({
    required String productId,
    required String imageUrl,
  });
}

/// Adaptateur temporaire de développement : conserve une URL HTTPS fournie.
/// Il ne téléverse aucun fichier local et ne remplace pas Firebase Storage.
class TemporaryUrlImageStorage implements ProductImageStorage {
  @override
  Future<StoredProductImage> saveExternalUrl({
    required String productId,
    required String imageUrl,
  }) async {
    final uri = Uri.tryParse(imageUrl.trim());
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      throw const FormatException(
        'L’image doit utiliser une URL HTTPS valide.',
      );
    }
    return StoredProductImage(imageUrl: uri.toString());
  }
}
