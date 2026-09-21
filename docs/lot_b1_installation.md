# Vendora — Lot B1 : catégories réelles et modèles du catalogue

## Portée

Ce lot suit le lot UI A. Il ajoute la consultation publique des catégories depuis Cloud Firestore et prépare les modèles des futurs produits. Le téléversement d’images attend la décision concernant Firebase Storage ou une alternative autorisée par l’enseignant.

- Aucun changement de plan Firebase : Spark reste suffisant pour ces opérations dans ses quotas.
- Aucune dépendance Dart supplémentaire.
- Aucune image distante requise : les catégories utilisent des icônes Material locales.
- Aucun produit de démonstration ni chiffre fictif ajouté à la base.
- Aucun formulaire de création/édition de produit dans ce lot.
- Les produits et commandes restent interdits dans les règles tant que leurs modules ne sont pas en place.

## 1. Installation locale — terminal / VS Code

Arrêter `flutter run` avec `q`. Depuis le terminal :

```bash
cd ~/develop/vendora

tar -czf "../vendora_avant_b1_$(date +%Y%m%d_%H%M%S).tar.gz" \
  lib test docs firestore.rules pubspec.yaml pubspec.lock
```

Si le fichier local `firestore.rules` n’existe pas, vérifier son nom et sauvegarder aussi les règles actuelles depuis la console avant de poursuivre.

Placer `vendora_catalogue_b1.zip` à côté de `pubspec.yaml`, puis :

```bash
unzip -o vendora_catalogue_b1.zip
flutter pub get
dart format lib test
flutter analyze
flutter test
```

Ne pas modifier `main.dart`, `firebase_options.dart`, les services Authentication ou le thème. Ils ne figurent pas dans ce patch.

## 2. Publier les règles — console Firebase

Le fichier de règles doit être publié ; l’extraction locale ne le déploie pas.

1. Ouvrir le projet `vendora-19a5c` dans Firebase Console.
2. Firestore Database → Rules.
3. Sauvegarder les règles existantes avant tout remplacement.
4. Copier l’intégralité du nouveau fichier local `firestore.rules` et remplacer les règles de la console.
5. Publier.

Cette version conserve exactement les règles des profils fournies précédemment et ajoute :

```text
match /categories/{categoryId} {
  allow get, list: if resource.data.isActive == true;
  allow create, update, delete: if false;
}
```

Les catégories actives sont publiques. Les documents inactifs ne peuvent pas être lus via l’application. Les visiteurs, clients et vendeurs ne peuvent pas créer/modifier/supprimer le référentiel depuis leurs SDK.

L’administration du référentiel se fait pour l’instant depuis la console Firebase, avec les droits administrateur du responsable du projet. La console utilise ces autorisations administratives : elle n’est pas un test des permissions d’un client Flutter.

**Important :** une requête sur toute la collection serait refusée. Les règles ne filtrent pas les résultats à la place de l’application. Le repository utilise explicitement :

```dart
_firestore.collection('categories')
  .where('isActive', isEqualTo: true)
  .snapshots();
```

Le tri se fait localement sur ce petit référentiel, d’abord par sortOrder, puis par nom et identifiant. Aucun index composite supplémentaire n’est demandé par cette requête ; garder l’indexation standard du champ isActive.

Si vous avez ajouté d’autres règles depuis le lot précédent, ne pas les écraser aveuglément : fusionner le bloc categories et conserver vos règles validées.

## 3. Ajouter une première catégorie — console Firebase

Pour commencer, une seule catégorie suffit.

1. Firestore Database → Data.
2. Cliquer sur **Start collection / Démarrer une collection**.
3. Collection ID : `categories` (minuscules, sans espace).
4. Document ID : `tech` (ne pas choisir un ID automatique ici).
5. Ajouter les cinq champs suivants en respectant les types :

| Champ | Type dans la console | Valeur |
|---|---|---|
| name | string | Tech |
| description | string | Les essentiels connectés. |
| iconKey | string | tech |
| sortOrder | number | 1 |
| isActive | boolean | true |

6. Enregistrer.

Attention : `true` doit être le booléen true, pas le texte "true". sortOrder doit être le nombre entier 1, pas la chaîne "1" ni un nombre décimal.

L’identifiant `tech` est le nom du document : ne pas ajouter un champ `id` en plus.

## 4. Catégories suivantes — quand la première fonctionne

Dans la collection categories, utiliser **Add document** :

| Document ID | name | description | iconKey | sortOrder | isActive |
|---|---|---|---|---|---|
| mode | Mode | Des tenues pour le quotidien. | fashion | 2 | true |
| accessoires | Accessoires | Les détails qui font la différence. | accessories | 3 | true |
| maison | Maison | Un intérieur qui vous ressemble. | home | 4 | true |

Types identiques au premier document. `docs/categories_reference.json` rassemble ces valeurs comme référence. Ce n’est pas un script d’import : Firebase Console ne crée pas automatiquement les documents à partir de ce fichier, et le code Flutter ne le charge pas.

Description et iconKey sont facultatifs dans le modèle ; name, sortOrder et isActive sont obligatoires. Une clé d’icône inconnue affiche une icône générique. N’enregistrer aucune information privée dans les catégories publiques.

## 5. Aperçu local pendant la préparation

Tant que Firestore ne contient aucune catégorie active, l’application affiche désormais quatre cartes locales de présentation : Tech, Mode, Accessoires et Maison. Un bandeau indique clairement **« Aperçu local »** : ces cartes ne sont pas des données Firebase et ne peuvent pas être commandées.

Dès qu’au moins une catégorie active existe dans Firestore, l’aperçu local disparaît automatiquement et l’application affiche uniquement les catégories réelles. Les données Firestore restent donc la source de vérité de l’application finale.

Cette solution permet de continuer la maquette sans inventer de produits ou de statistiques. Pour rendre les catégories réelles, créer les documents indiqués à la section 3 et 4.

## 6. Vérification dans Flutter

```bash
flutter run -d chrome
```

- Sans connexion : le bouton **Voir les catégories** est sur l’accueil visiteur.
- Avec un compte client : onglet **Accueil** → Voir les catégories.
- Avec un compte vendeur : onglet **Boutique** → Voir les catégories.

Résultat attendu : Tech apparaît depuis Firestore. Une catégorie supplémentaire créée dans la console apparaît grâce au flux temps réel, sans ajout dans le code Dart.

La recherche porte uniquement sur le nom des catégories chargées. Elle ignore la casse, mais ne fait pas de recherche plein texte ni de normalisation des accents. Le filtrage des produits arrivera dans leur module.

Cliquer sur une catégorie ouvre ses informations et indique clairement que les produits seront ajoutés ensuite. Ce n’est pas encore une liste de produits.

## 6. Tester la persistance et les états

- Actualiser Chrome : la catégorie reste disponible car elle est stockée dans Firestore.
- Ajouter une seconde catégorie dans la console : la liste se met à jour.
- Mettre isActive à false sur Tech : elle disparaît du catalogue public ; remettre true la fait revenir.
- Rechercher un nom inexistant : état « Aucun résultat », puis effacer le filtre.
- Sans aucune catégorie active : état vide, pas de produits de démonstration.
- En cas de permission refusée : vérifier le projet, la publication des règles et l’orthographe du champ isActive.
- Si un document a un mauvais type, l’application affiche une erreur contrôlée ; corriger le document depuis la console.

Le SDK Firestore peut afficher des données en cache : voir une liste hors ligne ne prouve pas un accès réseau actif. Les données doivent aussi être vérifiées dans la console.

## 7. Structure des fichiers

```text
lib/core/models/app_currency.dart
lib/core/utils/firestore_values.dart
lib/features/catalog/
  models/
    category.dart
    product.dart
  data/
    category_repository.dart
  presentation/
    screens/
      categories_screen.dart
    widgets/
      category_icon.dart
      category_list_body.dart
```

Fichiers existants remplacés :

- `lib/features/auth/presentation/widgets/welcome_content.dart` : ajout du bouton et mise à jour du message d’accueil.
- `firestore.rules` : ajout de la lecture publique des catégories actives, sans changement des droits des profils.

Fichiers de tests ajoutés :

- `test/unit/catalog_models_test.dart`.
- `test/widgets/categories_screen_test.dart`.

## 8. Contrat préparé pour les produits — ne pas encore créer ces documents

Collection future : `products/{productId}`.

| Champ | Type | Rôle |
|---|---|---|
| name | string | Nom produit, 2–120 caractères |
| description | string | Description, 1–3 000 caractères |
| priceMinor | integer | Prix strictement positif en unités monétaires entières |
| currency | string | BIF, USD ou EUR |
| categoryId | string | Identifiant du document de catégorie |
| stock | integer | Quantité, de 0 à 1 000 000 |
| imageUrl | string | URL HTTPS de l’image persistante |
| imagePath | string ou null | Chemin Storage si ce service est retenu |
| sellerId | string | UID vendeur |
| sellerName | string | Nom commercial/profil vendeur associé |
| sellerWhatsappNumber | string | Numéro international |
| isActive | boolean | Publication du produit |
| createdAt | timestamp | Date serveur de création |
| updatedAt | timestamp | Date serveur de modification |

BIF : 135 000 BIF → priceMinor = 135000. USD/EUR : 12,99 → priceMinor = 1299. Aucun taux de conversion n’est appliqué dans ce lot.

`Product.fromMap` lit et vérifie le format des documents. Les dates sont converties en UTC dans le modèle. Les futurs formulaires et règles sécuriseront l’écriture. Ce parser n’est PAS un contrôle d’autorisation et ne vérifie pas à lui seul l’existence du vendeur ou de la catégorie.

Une URL HTTPS n’est pas une garantie de pérennité de l’image : l’hébergement final doit encore être choisi. Les chemins temporaires locaux et les URL blob/file sont refusés. Aucune image n’est envoyée ni téléchargée par ce lot.

`isInStock` est une indication locale d’affichage, pas une réservation : le stock devra être revérifié à la commande dans le futur module sécurisé.

## 9. Tests et limites

Validation locale sur le projet reconstitué des lots précédents avec Flutter 3.47.5 / Dart 3.13.4 :

- `flutter analyze` : aucun problème.
- `flutter test` : **63 tests réussis** (35 précédents + 28 nouveaux).
- Compilation Web release réussie.
- Nouveaux tests : modèles, types invalides, prix/stock, URL d’image locale refusée, ordre des catégories, chargement, recherche, absence de données, erreur et réessai, mise à jour du flux, écran 320 pixels et texte agrandi.

Les tests widgets utilisent une source de catégories de test injectée. L’application normale utilise CategoryRepository avec FirebaseFirestore.instance. Les données de test sont uniquement dans test/.

Les règles n’ont pas été exécutées dans un émulateur ou contre votre projet Firebase dans cet environnement. La publication et les essais sur votre console restent nécessaires. Les essais depuis la console administrateur ne démontrent pas les droits d’un client Flutter.

Tests de droits à prévoir avec le simulateur de règles ou des clients de test : lecture publique active autorisée ; lecture inactive refusée ; écriture catégorie par visiteur/client/vendeur refusée ; profil d’un autre utilisateur toujours inaccessible ; produits/commandes toujours fermés à ce stade.

## Prochain lot

Après validation de cette base : service produits et CRUD vendeur, avec stratégie d’images durables validée avant d’ouvrir le téléversement. Nous conserverons la palette et les composants déjà approuvés pour le catalogue, les fiches et la gestion des produits.
