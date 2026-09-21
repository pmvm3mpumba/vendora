import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../providers/auth_controller.dart';
import '../widgets/auth_page.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'session_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showLogin = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (!auth.ready) {
      return const Scaffold(body: Center(
        child: CircularProgressIndicator(semanticsLabel: 'Chargement de la session'),
      ));
    }
    if (auth.sessionError != null) {
      return AuthPage(title: 'Session indisponible', children: [
        AuthErrorText(message: auth.sessionError),
        AppButton(label: 'Réessayer', onPressed: () => auth.retryProfile()),
        const SizedBox(height: AppSpacing.md),
        AuthErrorText(message: auth.operationError),
        if (auth.isAuthenticated)
          AppButton(label: 'Se déconnecter', isLoading: auth.busy,
              variant: AppButtonVariant.secondary,
              onPressed: () => auth.signOut()),
      ]);
    }
    if (auth.isAuthenticated) {
      final profile = auth.profile;
      if (profile == null) {
        // Garder le formulaire monté pendant l'enregistrement pour ne pas
        // perdre les valeurs saisies si Firestore renvoie une erreur.
        return const RegisterScreen(completeProfileOnly: true);
      }
      return SessionScreen(profile: profile);
    }
    if (_showLogin) {
      return LoginScreen(onVisit: () {
        auth.clearOperationError();
        setState(() => _showLogin = false);
      });
    }
    return AuthPage(title: 'Bienvenue sur Vendora', children: [
      AppStateView(
        icon: Icons.storefront_outlined,
        title: 'Vous naviguez sans compte',
        message: 'Le catalogue public sera ajouté au module produits. '
            'Un compte sera nécessaire pour commander ou vendre.',
        action: AppButton(label: 'Se connecter ou créer un compte',
            onPressed: () {
              auth.clearOperationError();
              setState(() => _showLogin = true);
            }),
      ),
    ]);
  }
}
