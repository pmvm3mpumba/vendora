# Étape 1 — Thème et composants communs

## Contenu

Ce lot contient 10 fichiers Dart et ce guide. Il ne remplace ni pubspec.yaml, ni les dossiers android/web, ni la configuration Firebase. Aucun package tiers n'est nécessaire. Utiliser un SDK Flutter stable récent (Dart 3).

L'écran FoundationScreen est un aperçu temporaire, pas un catalogue connecté. La recherche est volontairement désactivée. Pas de comptes, de produits ou de ventes fictives.

## Installation

1. Arrêter `flutter run` avec `q`.
2. Se placer dans `~/Projets/exam_shop`.
3. Sauvegarder au minimum `lib/main.dart` et `test/widget_test.dart`, ou faire un commit Git.
4. Extraire l'archive à la racine du projet. Elle contient directement `lib/`, `test/` et `docs/`.
5. Attention : `lib/main.dart` et `test/widget_test.dart` remplacent les fichiers générés par Flutter. Si les autres fichiers existent déjà, comparer avant de remplacer.
6. Exécuter :

```bash
dart format lib test
flutter analyze
flutter test
flutter run -d chrome
```

Ne pas conserver l'ancien test du compteur : il ne correspond plus à l'application.

## Responsabilités

- main.dart : point d'entrée minimal.
- app/app.dart : MaterialApp et thème ; les providers et le routeur viendront plus tard.
- app/foundation_screen.dart : écran provisoire de vérification visuelle.
- core/theme/app_colors.dart : palette centrale.
- core/theme/app_spacing.dart : dimensions communes.
- core/theme/app_theme.dart : thème Material 3, typographie, boutons, champs et notifications.
- core/widgets/app_button.dart : variantes primaire/secondaire et chargement bloquant les clics.
- core/widgets/app_text_field.dart : champ réutilisable compatible avec Form et validator.
- core/widgets/app_state_view.dart : message vide/erreur/information réutilisable.
- test/widget_test.dart : tests de base (affichage, interaction, chargement, petit écran).

## Principes

Orange principal #C2410C ; accent #FF6A00 ; fond #F5F6F8 ; cartes blanches. Police système, sans accès à Google Fonts. Texte adaptable au réglage d'accessibilité. Page défilante et largeur maximale 640 pour cet aperçu, pas une limite imposée au futur catalogue. Les futurs écrans utilisent Theme.of(context), les composants communs et les espacements centralisés.

## Validation manuelle

- Vérifier l'affichage à une largeur de téléphone et de bureau.
- Le bouton principal affiche une notification.
- Le bouton secondaire ouvre un dialogue que l'on peut fermer.
- La recherche est désactivée et aucun accès Firebase n'est prétendu.
- Vérifier l'agrandissement du texte dans Chrome.

## Limite de vérification

Les fichiers ont été préparés sans SDK Flutter disponible dans l'environnement de génération. Les commandes flutter analyze et flutter test doivent donc être exécutées sur la machine de développement ; leur réussite n'a pas été vérifiée ici.

## Prochaine étape

Installer/configurer Firebase CLI et FlutterFire CLI, choisir l'identifiant Android définitif, puis connecter Android et Web au même projet Firebase. L'authentification vient ensuite.
