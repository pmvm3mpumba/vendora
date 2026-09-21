import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendora/core/theme/app_theme.dart';
import 'package:vendora/features/catalog/data/category_repository.dart';
import 'package:vendora/features/catalog/models/category.dart';
import 'package:vendora/features/catalog/presentation/screens/categories_screen.dart';
import 'package:vendora/features/catalog/presentation/widgets/category_icon.dart';

const tech = Category(
  id: 'tech',
  name: 'Tech',
  description: 'Les essentiels connectés.',
  iconKey: 'tech',
  sortOrder: 1,
  isActive: true,
);
const fashion = Category(
  id: 'mode',
  name: 'Mode',
  description: 'Des tenues pour le quotidien.',
  iconKey: 'fashion',
  sortOrder: 2,
  isActive: true,
);

class TestCategorySource implements CategorySource {
  TestCategorySource(this.factory);
  final Stream<List<Category>> Function(int call) factory;
  int calls = 0;
  @override
  Stream<List<Category>> watchActive() => factory(++calls);
}

Widget host(CategorySource source, {double scale = 1}) => MaterialApp(
  theme: AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: CategoriesScreen(source: source),
);

void main() {
  test('Les icônes inconnues ont une alternative locale', () {
    expect(CategoryIcon.resolve('unknown'), Icons.category_outlined);
    expect(CategoryIcon.resolve('tech'), Icons.devices_other_outlined);
  });

  testWidgets('Affiche le chargement puis les données reçues', (tester) async {
    final stream = StreamController<List<Category>>();
    addTearDown(stream.close);
    final source = TestCategorySource((_) => stream.stream);
    await tester.pumpWidget(host(source));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    stream.add([tech, fashion]);
    await tester.pumpAndSettle();
    expect(find.text('Tech'), findsOneWidget);
    expect(find.text('Mode'), findsOneWidget);
    expect(source.calls, 1);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Affiche un état vide sans inventer de catégorie', (
    tester,
  ) async {
    await tester.pumpWidget(host(TestCategorySource((_) => Stream.value([]))));
    await tester.pumpAndSettle();
    expect(find.text('Les catégories arrivent bientôt'), findsOneWidget);
    expect(find.byKey(const Key('category_tech')), findsNothing);
  });

  testWidgets('Recherche locale et effacement du filtre', (tester) async {
    await tester.pumpWidget(
      host(TestCategorySource((_) => Stream.value([tech, fashion]))),
    );
    await tester.pumpAndSettle();
    final search = find.descendant(
      of: find.byKey(const Key('category_search')),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(search, 'tech');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('category_tech')), findsOneWidget);
    expect(find.byKey(const Key('category_mode')), findsNothing);
    await tester.enterText(search, 'introuvable');
    await tester.pumpAndSettle();
    expect(find.text('Aucun résultat'), findsOneWidget);
    await tester.ensureVisible(find.text('Effacer la recherche'));
    await tester.tap(find.text('Effacer la recherche'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('category_mode')), findsOneWidget);
  });

  testWidgets('Une permission refusée est expliquée et le réessai fonctionne', (
    tester,
  ) async {
    final source = TestCategorySource(
      (call) => call == 1
          ? Stream.error(
              FirebaseException(
                plugin: 'cloud_firestore',
                code: 'permission-denied',
              ),
            )
          : Stream.value([tech]),
    );
    await tester.pumpWidget(host(source));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('lecture des catégories est refusée'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Réessayer'));
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(source.calls, 2);
    expect(find.byKey(const Key('category_tech')), findsOneWidget);
  });

  testWidgets('Un document mal formé produit une erreur contrôlée', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        TestCategorySource(
          (_) => Stream.error(const FormatException('invalid name')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('champs invalides'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('La fiche explique que le module produits reste à venir', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(TestCategorySource((_) => Stream.value([tech]))),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('category_tech')));
    await tester.tap(find.byKey(const Key('category_tech')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('La liste de ses produits sera ajoutée'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Retour aux catégories'));
    await tester.tap(find.text('Retour aux catégories'));
    await tester.pumpAndSettle();
    expect(find.text('Retour aux catégories'), findsNothing);
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets('Pas de débordement à 320 pixels, texte ×$scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        host(
          TestCategorySource((_) => Stream.value([tech, fashion])),
          scale: scale,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byKey(const Key('category_mode')));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'Une mise à jour du flux rafraîchit la liste sans recharger la source',
    (tester) async {
      final stream = StreamController<List<Category>>();
      addTearDown(stream.close);
      final source = TestCategorySource((_) => stream.stream);
      await tester.pumpWidget(host(source));
      stream.add([tech]);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('category_mode')), findsNothing);
      stream.add([tech, fashion]);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('category_mode')), findsOneWidget);
      expect(source.calls, 1);
    },
  );
}
