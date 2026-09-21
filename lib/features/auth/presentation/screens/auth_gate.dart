import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/vendora_logo.dart';
import '../../providers/auth_controller.dart';
import '../widgets/auth_page.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'session_screen.dart';
import 'visitor_screen.dart';

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
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const VendoraLogo(large: true),
                  const SizedBox(height: AppSpacing.xxl),
                  const CircularProgressIndicator(
                    semanticsLabel: 'Chargement de la session',
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Préparation de votre espace…',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    if (auth.sessionError != null) {
      return AuthPage(
        title: 'Retrouvons votre espace.',
        subtitle: 'Le chargement de votre session n’a pas pu se terminer.',
        badge: 'Connexion interrompue',
        children: [
          AuthErrorText(message: auth.sessionError),
          AppButton(
            label: 'Réessayer',
            icon: Icons.refresh_rounded,
            onPressed: () => auth.retryProfile(),
          ),
          const SizedBox(height: AppSpacing.md),
          AuthErrorText(message: auth.operationError),
          if (auth.isAuthenticated)
            AppButton(
              label: 'Se déconnecter',
              isLoading: auth.busy,
              variant: AppButtonVariant.secondary,
              onPressed: () => auth.signOut(),
            ),
        ],
      );
    }
    if (auth.isAuthenticated) {
      final profile = auth.profile;
      if (profile == null) {
        return const RegisterScreen(completeProfileOnly: true);
      }
      return SessionScreen(key: ValueKey(profile.id), profile: profile);
    }
    if (_showLogin) {
      return LoginScreen(
        onVisit: () {
          auth.clearOperationError();
          setState(() => _showLogin = false);
        },
      );
    }
    return VisitorScreen(
      onSignIn: () {
        auth.clearOperationError();
        setState(() => _showLogin = true);
      },
      onRegister: () {
        auth.clearOperationError();
        // Le retour depuis l'inscription mène à la connexion, pas à une impasse.
        setState(() => _showLogin = true);
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const RegisterScreen()));
      },
    );
  }
}
