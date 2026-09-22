# Stratégie d’images Vendora

## Implémentation actuelle

Le code utilise `ProductImageStorage` et `TemporaryUrlImageStorage`.

Cette version accepte seulement une URL HTTPS publique et la valeur enregistrée dans Firestore est `imageUrl`. Elle est destinée au développement et aux données de démonstration. Elle ne téléverse pas les fichiers locaux.

Un chemin local tel que `/storage/.../image.jpg` ne doit jamais être enregistré dans Firestore comme image publique : les autres appareils ne pourraient pas le lire.

## Remplacement futur

Lorsque l’hébergement final est validé, créer une implémentation Firebase Storage de la même interface, par exemple :

```text
FirebaseStorageImageStorage implements ProductImageStorage
```

Cette implémentation devra envoyer le fichier vers :

```text
product-images/{sellerId}/{productId}/{imageId}.jpg
```

Puis renvoyer :

```text
StoredProductImage(
  imageUrl: downloadUrl,
  imagePath: storagePath,
)
```

Le formulaire vendeur et le catalogue continueront à utiliser `ProductImageStorage`; seul le branchement de l’implémentation changera.

## Limites actuelles

- Les URL externes nécessitent Internet.
- Un fournisseur externe peut supprimer ou modifier une image.
- Firebase Storage n’est pas encore activé dans ce lot.
- Ne pas présenter l’URL temporaire comme la solution finale de téléversement de l’examen.
- Le produit doit afficher une icône de secours si l’image échoue.
