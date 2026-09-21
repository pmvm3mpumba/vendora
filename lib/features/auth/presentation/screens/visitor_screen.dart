import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/vendora_logo.dart';
import '../widgets/welcome_content.dart';

class VisitorScreen extends StatelessWidget {
  const VisitorScreen({
    super.key,
    required this.onSignIn,
    required this.onRegister,
  });
  final VoidCallback onSignIn;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const VendoraLogo(),
        actions: [
          IconButton(
            tooltip: 'Se connecter',
            onPressed: onSignIn,
            icon: const Icon(Icons.person_outline_rounded),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.pageMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const WelcomeContent(),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: 'Se connecter',
                    onPressed: onSignIn,
                    icon: Icons.arrow_forward_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Créer un compte',
                    onPressed: onRegister,
                    variant: AppButtonVariant.secondary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'La consultation du futur catalogue restera accessible sans compte.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
