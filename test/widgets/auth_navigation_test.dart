import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vendora/core/theme/app_theme.dart';
import 'package:vendora/core/widgets/app_button.dart';
import 'package:vendora/features/auth/data/auth_repository.dart';
import 'package:vendora/features/auth/models/app_user.dart';
import 'package:vendora/features/auth/presentation/screens/auth_gate.dart';
import 'package:vendora/features/auth/providers/auth_controller.dart';

// Doubles de test uniquement : jamais importés par lib/.
class _User extends Fake implements User {
  @override
  String get uid => 'test-uid';
  @override
  String get email => 'test@example.com';
}

// Double de test local : aucune sous-classe de DocumentSnapshot dans le code applicatif.
// ignore: subtype_of_sealed_class
class _Snapshot extends Fake implements DocumentSnapshot<Map<String, dynamic>> {
  _Snapshot(this._data);
  final Map<String, dynamic>? _data;
  @override
  String get id => 'test-uid';
  @override
  Map<String, dynamic>? data() => _data;
}

class _Repository extends Fake implements AuthRepository {
  final _auth = StreamController<User?>.broadcast();
  final _profiles =
      StreamController<DocumentSnapshot<Map<String, dynamic>>>.broadcast();
  User? _user;
  Map<String, dynamic>? _data;
  bool rejectPassword = false;
  bool failProfileOnce = false;

  @override
  User? get currentUser => _user;
  @override
  Stream<User?> get authChanges => Stream.multi((controller) {
    controller.add(_user);
    final subscription = _auth.stream.listen(controller.add);
    controller.onCancel = subscription.cancel;
  });

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchProfile(String uid) {
    return Stream.multi((controller) {
      controller.add(_Snapshot(_data));
      final subscription = _profiles.stream.listen(controller.add);
      controller.onCancel = subscription.cancel;
    });
  }

  @override
  Future<void> signIn(String email, String password) async {
    if (rejectPassword) throw FirebaseAuthException(code: 'invalid-credential');
    _user = _User();
    _auth.add(_user);
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
    required String whatsappNumber,
  }) async {
    await signIn(email, password);
    if (failProfileOnce) {
      failProfileOnce = false;
      throw FirebaseException(plugin: 'cloud_firestore', code: 'unavailable');
    }
    await completeProfile(
      name: name,
      phone: phone,
      role: role,
      whatsappNumber: whatsappNumber,
    );
  }

  @override
  Future<void> completeProfile({
    required String name,
    required String phone,
    required UserRole role,
    required String whatsappNumber,
  }) async {
    _data = {
      'name': name,
      'email': 'test@example.com',
      'phone': phone,
      'role': role.name,
      'whatsappNumber': whatsappNumber,
      'createdAt': null,
    };
    _profiles.add(_Snapshot(_data));
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _auth.add(null);
  }

  Future<void> close() async {
    await _auth.close();
    await _profiles.close();
  }
}

Future<void> _start(WidgetTester tester, _Repository repository) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => AuthController(repository),
      child: MaterialApp(theme: AppTheme.light, home: const AuthGate()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder target) async {
  await tester.pumpAndSettle();
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  // Les annulations de StreamSubscription du double peuvent terminer hors
  // de l'horloge simulée de testWidgets ; laisser passer un tour asynchrone.
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pumpAndSettle();
}

Future<void> _fill(WidgetTester tester, String key, String text) async {
  final target = find.descendant(
    of: find.byKey(Key(key)),
    matching: find.byType(TextFormField),
  );
  await tester.ensureVisible(target);
  await tester.enterText(target, text);
  await tester.pumpAndSettle();
}

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;

  for (final role in UserRole.values) {
    testWidgets(
      'Inscription ${role.name} : route fermée, bon profil, déconnexion',
      (tester) async {
        final repo = _Repository();
        addTearDown(repo.close);
        await _start(tester, repo);
        await _tap(tester, find.widgetWithText(AppButton, 'Créer un compte'));
        if (role == UserRole.seller) {
          await _tap(tester, find.byKey(const Key('role_seller')));
        }
        await _fill(tester, 'register_name', 'Profil Test');
        await _fill(tester, 'register_email', 'test@example.com');
        await _fill(tester, 'register_phone', '+25779123456');
        if (role == UserRole.seller) {
          await _fill(tester, 'register_whatsapp', '+25779123457');
        }
        await _fill(tester, 'register_password', 'Test12345!');
        await _fill(tester, 'register_confirm', 'Test12345!');
        await _tap(tester, find.byKey(const Key('register_submit')));
        expect(find.text('Profil Test'), findsOneWidget);
        expect(
          find.text(
            role == UserRole.client
                ? 'Votre espace client'
                : 'Votre espace vendeur',
          ),
          findsOneWidget,
        );
        expect(find.byKey(const Key('register_submit')), findsNothing);
        await _tap(tester, find.text('Se déconnecter'));
        expect(repo.currentUser, isNull);
        expect(find.byKey(const Key('login_submit')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Un compte restauré ouvre directement son profil', (
    tester,
  ) async {
    final repo = _Repository();
    addTearDown(repo.close);
    await repo.completeProfile(
      name: 'Session restaurée',
      phone: '+25779123456',
      role: UserRole.client,
      whatsappNumber: '',
    );
    await repo.signIn('test@example.com', 'Test12345!');
    await _start(tester, repo);
    expect(find.text('Session restaurée'), findsOneWidget);
    expect(find.byKey(const Key('login_submit')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Une mauvaise connexion affiche l’erreur sans ouvrir un compte', (
    tester,
  ) async {
    final repo = _Repository()..rejectPassword = true;
    addTearDown(repo.close);
    await _start(tester, repo);
    await _tap(tester, find.widgetWithText(AppButton, 'Se connecter'));
    await _fill(tester, 'login_email', 'test@example.com');
    await _fill(tester, 'login_password', 'Mauvais123!');
    await _tap(tester, find.byKey(const Key('login_submit')));
    expect(find.text('Email ou mot de passe incorrect.'), findsOneWidget);
    expect(repo.currentUser, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Auth réussie et profil échoué : récupération sans recréer le compte',
    (tester) async {
      final repo = _Repository()..failProfileOnce = true;
      addTearDown(repo.close);
      await _start(tester, repo);
      await _tap(tester, find.widgetWithText(AppButton, 'Créer un compte'));
      await _fill(tester, 'register_name', 'Profil Test');
      await _fill(tester, 'register_email', 'test@example.com');
      await _fill(tester, 'register_phone', '+25779123456');
      await _fill(tester, 'register_password', 'Test12345!');
      await _fill(tester, 'register_confirm', 'Test12345!');
      await _tap(tester, find.byKey(const Key('register_submit')));
      expect(find.text('Terminons votre profil.'), findsOneWidget);
      expect(find.byKey(const Key('register_email')), findsNothing);
      expect(repo.currentUser, isNotNull);
      await _fill(tester, 'register_name', 'Profil récupéré');
      await _fill(tester, 'register_phone', '+25779123456');
      await _tap(tester, find.byKey(const Key('register_submit')));
      expect(find.text('Profil récupéré'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
