import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vendora/core/theme/app_theme.dart';
import 'package:vendora/core/widgets/app_button.dart';
import 'package:vendora/core/widgets/app_text_field.dart';

void main() {
  testWidgets('Le bouton exécute son action', (tester) async {
    var calls = 0;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: AppButton(
        label: 'Continuer', onPressed: () { calls++; },
      )),
    ));
    await tester.tap(find.text('Continuer'));
    expect(calls, 1);
  });

  testWidgets('Le chargement bloque la soumission', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: AppButton(
        label: 'Connexion', isLoading: true, onPressed: () {},
      )),
    ));
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Le formulaire affiche son erreur de validation', (tester) async {
    final key = GlobalKey<FormState>();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Form(key: key, child: AppTextField(
        label: 'Nom', validator: (value) => 'Champ obligatoire',
      ))),
    ));
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Champ obligatoire'), findsOneWidget);
  });
}
