import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendora/core/theme/app_colors.dart';
import 'package:vendora/core/theme/app_theme.dart';
import 'package:vendora/core/widgets/app_button.dart';
import 'package:vendora/core/widgets/app_text_field.dart';
import 'package:vendora/features/auth/models/app_user.dart';
import 'package:vendora/features/auth/presentation/screens/visitor_screen.dart';
import 'package:vendora/features/auth/presentation/widgets/account_content.dart';
import 'package:vendora/features/auth/presentation/widgets/login_form.dart';
import 'package:vendora/features/auth/presentation/widgets/registration_form.dart';

Widget host(Widget child, {double scale = 1}) => MaterialApp(
  theme: AppTheme.light,
  builder: (context, body) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: body!,
  ),
  home: child,
);

Finder input(String key) => find.descendant(
  of: find.byKey(Key(key)),
  matching: find.byType(TextFormField),
);

Future<void> fill(WidgetTester tester, String key, String value) async {
  await tester.ensureVisible(input(key));
  await tester.enterText(input(key), value);
}

Future<void> press(WidgetTester tester, String key) async {
  final target = find.byKey(Key(key));
  await tester.pumpAndSettle();
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pump();
}

void phoneSize(WidgetTester tester, {double width = 375, double height = 667}) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

const client = AppUser(
  id: 'client-test',
  name: 'Client de test',
  email: 'client@example.com',
  phone: '+25779123456',
  role: UserRole.client,
  whatsappNumber: '',
);
const seller = AppUser(
  id: 'seller-test',
  name: 'Vendeur de test',
  email: 'vendeur@example.com',
  phone: '+25779123456',
  role: UserRole.seller,
  whatsappNumber: '+25779123457',
);

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;
  test('Le thème applique la palette validée', () {
    expect(AppTheme.light.colorScheme.primary, AppColors.primary);
    expect(AppTheme.light.colorScheme.secondary, AppColors.secondary);
    expect(AppTheme.light.scaffoldBackgroundColor, AppColors.background);
  });

  testWidgets('La connexion refuse un formulaire vide', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      host(
        LoginForm(
          onSubmit: (_, _) async {
            calls++;
          },
          onRegister: () {},
          onVisit: () {},
        ),
      ),
    );
    await press(tester, 'login_submit');
    expect(calls, 0);
    expect(find.text('L’adresse email est obligatoire.'), findsOneWidget);
    expect(find.text('Le mot de passe est obligatoire.'), findsOneWidget);
  });

  testWidgets('La connexion transmet email nettoyé et mot de passe intact', (
    tester,
  ) async {
    String? email;
    String? password;
    await tester.pumpWidget(
      host(
        LoginForm(
          onSubmit: (e, p) async {
            email = e;
            password = p;
          },
          onRegister: () {},
          onVisit: () {},
        ),
      ),
    );
    await fill(tester, 'login_email', ' client@example.com ');
    await fill(tester, 'login_password', ' MotDePasse123! ');
    await press(tester, 'login_submit');
    await tester.pump();
    expect(email, 'client@example.com');
    expect(password, ' MotDePasse123! ');
  });

  testWidgets('Le mot de passe peut être affiché et masqué', (tester) async {
    await tester.pumpWidget(
      host(
        Scaffold(body: AppTextField(label: 'Mot de passe', obscureText: true)),
      ),
    );
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).obscureText,
      isTrue,
    );
    await tester.tap(find.byTooltip('Afficher le mot de passe'));
    await tester.pump();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).obscureText,
      isFalse,
    );
    await tester.tap(find.byTooltip('Masquer le mot de passe'));
    await tester.pump();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).obscureText,
      isTrue,
    );
  });

  testWidgets('Le formulaire bloque la double soumission pendant la requête', (
    tester,
  ) async {
    final pending = Completer<void>();
    var calls = 0;
    await tester.pumpWidget(
      host(
        LoginForm(
          onSubmit: (_, _) {
            calls++;
            return pending.future;
          },
          onRegister: () {},
          onVisit: () {},
        ),
      ),
    );
    await fill(tester, 'login_email', 'client@example.com');
    await fill(tester, 'login_password', 'Secret123!');
    await press(tester, 'login_submit');
    final button = tester.widget<FilledButton>(
      find.descendant(
        of: find.byKey(const Key('login_submit')),
        matching: find.byType(FilledButton),
      ),
    );
    expect(button.onPressed, isNull);
    expect(calls, 1);
    pending.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('Une erreur serveur reste lisible dans le formulaire', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        LoginForm(
          error: 'Email ou mot de passe incorrect.',
          onSubmit: (_, _) async {},
          onRegister: () {},
          onVisit: () {},
        ),
      ),
    );
    expect(find.text('Email ou mot de passe incorrect.'), findsOneWidget);
  });

  testWidgets('Les liens inscription et visiteur appellent leurs actions', (
    tester,
  ) async {
    var register = 0;
    var visit = 0;
    await tester.pumpWidget(
      host(
        LoginForm(
          onSubmit: (_, _) async {},
          onRegister: () {
            register++;
          },
          onVisit: () {
            visit++;
          },
        ),
      ),
    );
    await tester.ensureVisible(find.text('Créer un compte'));
    await tester.tap(find.text('Créer un compte'));
    await tester.ensureVisible(find.text('Continuer sans compte'));
    await tester.tap(find.text('Continuer sans compte'));
    expect(register, 1);
    expect(visit, 1);
  });

  testWidgets('Le numéro WhatsApp apparaît seulement pour le vendeur', (
    tester,
  ) async {
    await tester.pumpWidget(host(RegistrationForm(onSubmit: (_) async {})));
    expect(find.byKey(const Key('register_whatsapp')), findsNothing);
    await press(tester, 'role_seller');
    expect(find.byKey(const Key('register_whatsapp')), findsOneWidget);
    await press(tester, 'role_client');
    expect(find.byKey(const Key('register_whatsapp')), findsNothing);
  });

  testWidgets('Inscription client : données validées et rôle explicite', (
    tester,
  ) async {
    RegistrationData? submitted;
    await tester.pumpWidget(
      host(
        RegistrationForm(
          onSubmit: (data) async {
            submitted = data;
          },
        ),
      ),
    );
    await fill(tester, 'register_name', ' Client Test ');
    await fill(tester, 'register_email', 'client@example.com');
    await fill(tester, 'register_phone', '+25779123456');
    await fill(tester, 'register_password', 'Secret123!');
    await fill(tester, 'register_confirm', 'Secret123!');
    await press(tester, 'register_submit');
    await tester.pumpAndSettle();
    expect(submitted?.name, 'Client Test');
    expect(submitted?.role, UserRole.client);
    expect(submitted?.whatsappNumber, '');
  });

  testWidgets('Inscription vendeur : WhatsApp obligatoire', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      host(
        RegistrationForm(
          onSubmit: (_) async {
            calls++;
          },
        ),
      ),
    );
    await press(tester, 'role_seller');
    await fill(tester, 'register_name', 'Vendeur Test');
    await fill(tester, 'register_email', 'vendeur@example.com');
    await fill(tester, 'register_phone', '+25779123456');
    await fill(tester, 'register_password', 'Secret123!');
    await fill(tester, 'register_confirm', 'Secret123!');
    await press(tester, 'register_submit');
    expect(calls, 0);
    await fill(tester, 'register_whatsapp', '+25779123457');
    await press(tester, 'register_submit');
    await tester.pumpAndSettle();
    expect(calls, 1);
  });

  testWidgets('La confirmation différente est refusée', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      host(
        RegistrationForm(
          onSubmit: (_) async {
            calls++;
          },
        ),
      ),
    );
    await fill(tester, 'register_name', 'Client Test');
    await fill(tester, 'register_email', 'client@example.com');
    await fill(tester, 'register_phone', '+25779123456');
    await fill(tester, 'register_password', 'Secret123!');
    await fill(tester, 'register_confirm', 'Autre123!');
    await press(tester, 'register_submit');
    expect(calls, 0);
    expect(
      find.text('Les mots de passe ne correspondent pas.'),
      findsOneWidget,
    );
  });

  testWidgets('La récupération de profil ne redemande pas les identifiants', (
    tester,
  ) async {
    RegistrationData? submitted;
    await tester.pumpWidget(
      host(
        RegistrationForm(
          completeProfileOnly: true,
          onSubmit: (data) async {
            submitted = data;
          },
        ),
      ),
    );
    expect(find.byKey(const Key('register_email')), findsNothing);
    expect(find.byKey(const Key('register_password')), findsNothing);
    await fill(tester, 'register_name', 'Client Test');
    await fill(tester, 'register_phone', '+25779123456');
    await press(tester, 'register_submit');
    await tester.pumpAndSettle();
    expect(submitted?.name, 'Client Test');
    expect(submitted?.password, '');
  });

  testWidgets('Le profil client présente les vraies valeurs fournies', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      host(
        Scaffold(
          body: SingleChildScrollView(
            child: AccountContent(
              profile: client,
              onSignOut: () {
                calls++;
              },
            ),
          ),
        ),
      ),
    );
    expect(find.text(client.name), findsOneWidget);
    expect(find.text(client.email), findsOneWidget);
    expect(find.text('WhatsApp'), findsNothing);
    await tester.ensureVisible(find.text('Se déconnecter'));
    await tester.tap(find.text('Se déconnecter'));
    expect(calls, 1);
  });

  testWidgets('Le profil vendeur présente son numéro WhatsApp', (tester) async {
    await tester.pumpWidget(
      host(
        Scaffold(
          body: SingleChildScrollView(
            child: AccountContent(profile: seller, onSignOut: () {}),
          ),
        ),
      ),
    );
    expect(find.text(seller.whatsappNumber), findsOneWidget);
    expect(find.text('Vendeur'), findsOneWidget);
  });

  for (final width in [320.0, 375.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'Formulaires sans débordement : largeur $width, texte ×$scale',
        (tester) async {
          phoneSize(tester, width: width);
          await tester.pumpWidget(
            host(
              LoginForm(
                onSubmit: (_, _) async {},
                onRegister: () {},
                onVisit: () {},
              ),
              scale: scale,
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(find.byKey(const Key('login_submit')));
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(
            host(RegistrationForm(onSubmit: (_) async {}), scale: scale),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(find.byKey(const Key('register_submit')));
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('Un clavier ouvert ne masque pas définitivement le bouton', (
    tester,
  ) async {
    phoneSize(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 290);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(
      host(
        LoginForm(onSubmit: (_, _) async {}, onRegister: () {}, onVisit: () {}),
      ),
    );
    await tester.ensureVisible(find.byKey(const Key('login_submit')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('L’accueil visiteur affiche un état honnête et ses deux accès', (
    tester,
  ) async {
    phoneSize(tester);
    var signIn = 0;
    var register = 0;
    await tester.pumpWidget(
      host(
        VisitorScreen(
          onSignIn: () {
            signIn++;
          },
          onRegister: () {
            register++;
          },
        ),
      ),
    );
    expect(find.text('Le catalogue se prépare'), findsOneWidget);
    await tester.ensureVisible(find.widgetWithText(AppButton, 'Se connecter'));
    await tester.tap(find.widgetWithText(AppButton, 'Se connecter'));
    await tester.ensureVisible(
      find.widgetWithText(AppButton, 'Créer un compte'),
    );
    await tester.tap(find.widgetWithText(AppButton, 'Créer un compte'));
    expect(signIn, 1);
    expect(register, 1);
    expect(tester.takeException(), isNull);
  });
}
