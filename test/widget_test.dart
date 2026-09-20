import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// import '../lib/app/app.dart';
// import '../lib/core/theme/app_theme.dart';
// import '../lib/core/widgets/app_button.dart';

import 'package:vendora/app/app.dart';
import 'package:vendora/core/theme/app_theme.dart';
import 'package:vendora/core/widgets/app_button.dart';

void main() {
  testWidgets('Affiche la base de l’application', (tester) async {
    await tester.pumpWidget(const ExamShopApp());

    expect(find.text('Exam Shop'), findsOneWidget);
    expect(find.text('Les fondations sont prêtes'), findsOneWidget);
    expect(find.text('Rechercher un produit'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Le bouton principal affiche une confirmation', (tester) async {
    await tester.pumpWidget(const ExamShopApp());
    final button = find.text('Tester le bouton principal');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();

    expect(
      find.text('Thème prêt. Firebase sera connecté à la prochaine étape.'),
      findsOneWidget,
    );
  });

  testWidgets('Un bouton en chargement ne déclenche pas son action', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppButton(
            label: 'Confirmer',
            isLoading: true,
            onPressed: () {
              calls++;
            },
          ),
        ),
      ),
    );

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(calls, 0);
  });

  testWidgets('La page reste utilisable sur un petit écran', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ExamShopApp());
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Voir les prochaines étapes'));
    await tester.tap(find.text('Voir les prochaines étapes'));
    await tester.pumpAndSettle();
    expect(find.text('La suite du projet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
