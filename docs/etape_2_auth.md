# Étape 2 — Authentification et profils

## Préconditions

Projet Flutter `vendora` ; SDK Flutter stable récent ; Firebase déjà initialisé dans `main.dart` avec le fichier généré `firebase_options.dart`. Email/Password activé dans Authentication et base Firestore créée.

Le code utilise `DropdownButtonFormField.initialValue` et `PopScope` des versions récentes de Flutter. Si l'analyse signale un paramètre inconnu, vérifier la version du SDK et adapter avec l'aide de l'assistant plutôt que changer toutes les dépendances.

## Installation

1. Arrêter l'application.
2. Sauvegarder le projet ou faire un commit. L'archive remplace `lib/app/app.dart`, `test/widget_test.dart` et, s'il existe déjà, `firestore.rules`.
3. Extraire l'archive à la racine de `~/develop/vendora`.
4. Installer :

```bash
flutter pub add firebase_auth cloud_firestore provider
```

5. Dans Firebase Console → Firestore Database → Rules, remplacer les règles du projet dédié par le contenu du fichier `firestore.rules`, puis publier. Si des règles métier existent déjà, ne pas les écraser : cette version suppose que seul le module profils existe.
6. `dart format lib test`, `flutter analyze`, `flutter test`, `flutter run -d chrome`.

Aucun changement de `main.dart`, de `firebase_options.dart`, des configurations Android ou des ressources du thème n'est inclus. Le fichier `foundation_screen.dart` peut rester : il n'est plus utilisé comme accueil.

Les tests importent `package:vendora/...` : si `name:` dans pubspec.yaml diffère, adapter ces imports.

## Flux et état

- Sans session : écran visiteur temporaire, bouton de connexion et inscription. Pas de fausse liste de produits.
- AuthGate observe AuthController, qui observe Firebase Authentication puis le document users/{uid}.
- Après inscription : Firebase Auth crée l'identité ; Firestore stocke le profil.
- Selon le rôle Firestore : espace client ou vendeur provisoire.
- Déconnexion via Firebase Auth, pas par suppression d'une variable locale.
- La persistance standard du SDK Firebase Auth restaure la session dans le même profil de navigateur ; navigation privée/effacement des données modifient cette persistance.
- Aucun accès métier n'est accordé avant lecture d'un profil valide.

Auth et Firestore ne sont pas transactionnels ensemble. Si Auth réussit mais l'écriture du profil échoue, l'utilisateur reste authentifié et peut compléter son profil ; il ne doit pas recréer le même compte. Une erreur de permission de lecture affiche d'abord un écran d'erreur avec réessai. Corriger les règles publiées puis réessayer.

## Profil

users/{uid} : name, email, phone, role (client/seller), whatsappNumber, createdAt, updatedAt.

Tous les comptes fournissent un téléphone international ; vendeur : numéro WhatsApp obligatoire ; client : whatsappNumber vide. Aucun mot de passe dans Firestore. Les numéros d'exemple sont fictifs : utiliser un numéro de test approprié ; aucun message n'est envoyé à cette étape.

Les dates sont des serverTimestamp. Le rôle est choisi à la création, puis immuable pour le client applicatif. L'utilisateur peut consulter uniquement son profil. Les futures modifications de nom/téléphone/WhatsApp sont autorisées par les règles mais leur écran viendra ensuite.

Le minimum de 8 caractères est pour l'instant une validation Flutter. Pour l'imposer aussi aux appels directs Firebase Auth, configurer la politique de mot de passe dans Authentication selon les options disponibles, et garder UI/politique cohérentes. Les Rules Firestore ne valident pas les mots de passe.

## Sécurité

- Lecture propre profil uniquement ; liste globale interdite.
- Création uniquement sous son UID, champs contrôlés et email issu de l'identité Auth.
- Rôle client ou vendeur seulement ; changement de rôle interdit après création.
- Mise à jour limitée à name, phone, whatsappNumber, updatedAt.
- Suppression de profil interdite pour l'instant.
- Toutes les autres collections restent fermées, y compris produits et commandes. Les permissions publiques du catalogue seront ajoutées au module correspondant.

Ne jamais mettre `allow read, write: if true`. Le choix du rôle à l'inscription est voulu par le sujet ; aucune approbation administrative des vendeurs n'est prétendue.

## Tests automatisés inclus

10 tests locaux : bouton normal/chargement, validation de champ, validateurs des comptes et modèle AppUser. Ils n'initialisent pas Firebase et ne démontrent PAS le bon fonctionnement d'une inscription réelle ou des règles. Les anciens tests de la page de thème sont remplacés car l'accueil dépend maintenant de Firebase.

L'environnement de génération ne contient pas Flutter : ni l'analyse Dart, ni les tests Flutter, ni les règles Firebase n'y ont été exécutés. Les exécuter localement et valider les règles avant de considérer ce module terminé.

## Scénario de vérification réelle

1. Sans compte : accéder à l'accueil visiteur.
2. Créer un client avec une adresse de test valide et un mot de passe de test distinct de vos comptes personnels.
3. Vérifier Authentication → Users et Firestore → users/{même UID}.
4. Vérifier l'espace client, rafraîchir Chrome et vérifier la session.
5. Se déconnecter, vérifier la disparition de l'espace connecté.
6. Créer un vendeur avec un numéro WhatsApp international ; vérifier l'espace vendeur et son document.
7. Se déconnecter puis essayer un mauvais mot de passe.
8. Tester champs vides, email invalide, mot de passe trop court, confirmation différente et téléphone sans indicatif.
9. Couper la connexion pour une tentative de login et vérifier le message ; le comportement hors ligne Firestore diffère de celui d'Auth, ne pas assimiler un cache à une connexion réseau.
10. Tester la récupération de profil dans un projet de test : créer un compte Auth sans document users (console), se connecter puis compléter le profil.

## Vérifications Rules dans le simulateur de la console

Avec des documents de test existants et le simulateur Rules Playground (pas en modifiant les données directement avec l'accès administrateur de la console) :

- Sans authentification, lire users/{uidA} : refus.
- Authentifié comme uidA, lire users/{uidA} : autorisé.
- Authentifié comme uidA, lire users/{uidB} : refus.
- Authentifié comme uidA, lister users : refus.
- Authentifié comme uidA, modifier uniquement le rôle de users/{uidA} : refus.
- Authentifié comme uidA, écrire users/{uidB} : refus.

Les tests automatisés des Rules seront ajoutés dans un lot dédié. À ce stade nous ne prétendons pas avoir réalisé cet audit dans l'environnement de génération.

## Navigation et suite

Navigation simple Navigator + AuthGate dans ce module ; ne pas ajouter go_router en parallèle. Un routeur central sera introduit lorsque les routes catalogue/produits/commandes seront définies. AuthGate est une protection d'interface ; les Rules protègent les données.

Ce module ne contient pas encore : produits, commande, panier, édition du profil, mot de passe oublié, vérification email, stockage d'images ou appel WhatsApp. Priorité suivante : catégories et produits vendeur avec les règles adaptées.
