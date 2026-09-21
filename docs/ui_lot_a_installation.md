# Vendora — Lot UI A : identité, authentification et profils

## Livrable

Ce patch contient de vrais fichiers Dart pour le projet `vendora`. Il remplace la présentation provisoire des écrans d’authentification par le design validé : orange profond, vert secondaire, fonds clairs, cartes et boutons uniformisés.

**Il n’implémente pas encore le catalogue, le panier, les favoris, le checkout, les commandes ou les graphiques de la maquette HTML.** Ils seront intégrés aux vraies données dans les prochains lots. Ne pas confondre ce premier lot avec l’ensemble du projet terminé.

## Préconditions

- Votre application Vendora démarre déjà avec Firebase initialisé dans `lib/main.dart`.
- Les comptes client et vendeur, leurs profils Firestore, la connexion et la déconnexion ont été testés.
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `provider` sont déjà dans `pubspec.yaml`.
- Nom du package : `vendora` (utilisé dans les imports des tests).
- Les sources du module Authentication transmis précédemment sont présentes.
- Aucun nouveau package, aucune nouvelle image ni police distante n’est nécessaire.

## Installation sur Kali

Arrêter `flutter run` avec `q`. Depuis le terminal :

```bash
cd ~/develop/vendora

tar -czf "../vendora_avant_ui_lot_a_$(date +%Y%m%d_%H%M%S).tar.gz" \
  lib test pubspec.yaml pubspec.lock
```

Placer `vendora_ui_lot_a.zip` à côté de `pubspec.yaml`, puis :

```bash
unzip -o vendora_ui_lot_a.zip
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run -d chrome
```

Exécuter une commande à la fois et s’arrêter si une erreur apparaît. L’extraction remplace les fichiers du thème et des écrans listés plus bas : sauvegarder avant de l’exécuter.

Aucun déploiement de règles ou nouvelle commande FlutterFire n’est nécessaire pour ce patch. Ne pas remplacer `main.dart` ou `firebase_options.dart` par une ancienne version.

## Comportement attendu

- Sans session : accueil visiteur au nouveau style, avec connexion/inscription.
- Connexion : vrai appel au `AuthController` existant, gestion des erreurs et blocage de la soumission pendant la requête.
- Inscription : choix visuel Client/Vendeur, formulaire validé, WhatsApp obligatoire pour le vendeur, confirmation du mot de passe.
- Les champs de mot de passe possèdent un bouton afficher/masquer.
- Les formulaires sont défilants : l’inscription est naturellement plus longue qu’un écran de téléphone.
- Après connexion, on arrive sur les informations réelles de son compte, pas sur des statistiques de démonstration.
- Compte Auth sans profil Firestore : formulaire de récupération du profil conservé.
- Erreur de chargement du profil : écran d’erreur et réessai conservés.
- Déconnexion et restauration de session toujours confiées au contrôleur Firebase existant.
- Navigation à deux entrées pour ce lot : Accueil/Compte côté client, Boutique/Profil côté vendeur. Les autres destinations arriveront avec leurs fonctionnalités.
- La partie catalogue est explicitement indiquée « Le catalogue se prépare ». Elle n’effectue pas encore de requête produits et ne prétend pas que le catalogue est vide.
- Le profil est consultable, mais l’édition reste un lot ultérieur.

Si vous étiez déjà connecté, le premier écran peut être le compte. Déconnectez-vous pour voir les nouveaux formulaires.

## Ce qui ne change pas

Le patch ne contient PAS :

- `lib/main.dart` ;
- `lib/firebase_options.dart` ;
- `lib/app/app.dart` (sa classe `ExamShopApp` reste compatible) ;
- les modèles Firebase, `AuthRepository`, `AuthController` ou le mapping des erreurs Firebase ;
- `pubspec.yaml` / `pubspec.lock` ;
- les fichiers Android/Web générés ;
- `firestore.rules`, les index, les configurations de facturation.

Les rôles et autorisations restent ceux du module existant. Aucun sélecteur de changement de rôle n’est ajouté au profil. Les comptes et données Firebase ne sont pas supprimés.

Le validateur `auth_validators.dart` est inclus uniquement avec une mise en forme et des accolades compatibles avec l’analyseur ; ses critères de validation restent identiques.

## Fichiers modifiés

```text
lib/core/theme/app_colors.dart
lib/core/theme/app_spacing.dart
lib/core/theme/app_theme.dart
lib/core/validators/auth_validators.dart
lib/core/widgets/app_button.dart
lib/core/widgets/app_text_field.dart
lib/core/widgets/app_state_view.dart
lib/features/auth/presentation/widgets/auth_page.dart
lib/features/auth/presentation/screens/auth_gate.dart
lib/features/auth/presentation/screens/login_screen.dart
lib/features/auth/presentation/screens/register_screen.dart
lib/features/auth/presentation/screens/session_screen.dart
```

## Fichiers ajoutés

```text
lib/core/widgets/vendora_logo.dart
lib/core/widgets/app_notice.dart
lib/features/auth/presentation/widgets/login_form.dart
lib/features/auth/presentation/widgets/registration_form.dart
lib/features/auth/presentation/widgets/welcome_content.dart
lib/features/auth/presentation/widgets/account_content.dart
lib/features/auth/presentation/screens/visitor_screen.dart
test/widgets/auth_ui_test.dart
test/widgets/auth_navigation_test.dart
docs/ui_lot_a_installation.md
```

Les tests existants sont conservés. `foundation_screen.dart` peut rester, mais n’est plus utilisé comme écran d’accueil.

## Architecture de présentation

`LoginScreen` et `RegisterScreen` raccordent Provider aux formulaires. `LoginForm` et `RegistrationForm` gèrent la présentation et la saisie, et reçoivent des callbacks testables sans initialiser Firebase.

`AuthGate` continue à choisir l’espace selon l’état réel de la session et le profil. `SessionScreen` affiche `AccountContent` avec l’objet `AppUser` réel. Le `ValueKey` basé sur l’UID évite de conserver l’état visuel d’un compte précédent.

Les composants partagés centralisent la palette, les marges, les champs et boutons. Pas de dépendance à Google Fonts ni à un hébergeur d’images pour ce lot.

## Vérifications effectuées dans l’environnement de préparation

Projet de validation reconstitué à partir des fichiers des lots précédents, puis application du présent patch :

- Flutter 3.47.5 stable ; Dart 3.13.4.
- Versions résolues dans ce projet de validation : firebase_core 4.15.0, firebase_auth 6.7.0, cloud_firestore 6.10.0, provider 6.1.5+1.
- `flutter analyze` : **No issues found**.
- `flutter test` : **35 tests réussis** (10 précédents et 25 nouveaux).
- Compilation Web release du projet reconstitué réussie.
- Compilation Web d’un outil interne de capture des écrans réussie ; captures réalisées dans Chrome sans erreur JavaScript.
- Connexion/inscription visuellement vérifiées à une largeur de 390 pixels.
- Tests widgets de formulaires aux largeurs 320 et 375, texte à 100 % et 200 %, ainsi qu’avec un clavier simulé.

Les tests de navigation utilisent des doubles de repository dans `test/` : ce ne sont pas des comptes locaux dans le code applicatif. L’application réelle reste branchée sur Firebase via `AuthRepository`.

**Limites :** pas d’accès à votre console ou à vos comptes réels ; les règles et le réseau Firebase ne sont pas validés par ces tests locaux. Aucun APK Android n’a été compilé ici. Il faut refaire les essais ci-dessous sur votre projet. Les versions citées décrivent le test, elles ne demandent pas de modifier manuellement vos dépendances si tout fonctionne.

## Checklist sur votre machine

- [ ] L’analyse et les tests passent.
- [ ] Sans session, l’accueil affiche le nouveau style.
- [ ] Le bouton Connexion ouvre le nouveau formulaire.
- [ ] Un mauvais mot de passe affiche une erreur sans plantage.
- [ ] Le bouton afficher/masquer du mot de passe fonctionne.
- [ ] Un compte client existant ouvre son vrai profil.
- [ ] Un compte vendeur existant ouvre son profil avec WhatsApp.
- [ ] L’inscription client et vendeur fonctionne avec des comptes de test distincts.
- [ ] Après actualisation dans le même profil Chrome, la session est restaurée.
- [ ] Après déconnexion, les informations de l’ancien compte ne sont plus affichées.
- [ ] Le formulaire reste accessible avec le clavier, sur petit écran et texte agrandi.

Ne jamais partager les mots de passe ou jetons dans les captures.

## Retour arrière

En cas de besoin, conserver le patch et l’erreur pour diagnostic. L’archive `vendora_avant_ui_lot_a_...tar.gz` permet de restaurer les anciens fichiers `lib/` et `test/`. Une extraction simple de la sauvegarde remet les anciens fichiers, mais ne supprime pas les nouveaux fichiers ajoutés par le patch ; les supprimer uniquement d’après la liste ci-dessus si un retour strict est nécessaire. Ne pas supprimer `lib/` ni la configuration Firebase sans sauvegarde vérifiée.

## Prochain lot

Catégories et produits : modèles, accès Firestore, règles, CRUD vendeur et stratégie d’images durables validée. Puis la présentation catalogue/détail de la maquette sera branchée sur ces données. Le panier et les commandes suivront, puis les graphiques avec les vraies statistiques du vendeur.
