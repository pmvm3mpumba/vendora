import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../models/app_user.dart';
import '../../providers/auth_controller.dart';
import '../widgets/auth_page.dart';

/// Accueil connecté temporaire, remplacé par les vrais espaces métier plus tard.
class SessionScreen extends StatelessWidget {
  const SessionScreen({super.key, required this.profile});
  final AppUser profile;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return AuthPage(
      title: profile.isSeller ? 'Espace vendeur' : 'Espace client',
      children: [
        Text('Bienvenue, ${profile.name}',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.lg),
        Text('Rôle : ${profile.role.label}'),
        const SizedBox(height: AppSpacing.sm),
        Text('Email : ${profile.email}'),
        const SizedBox(height: AppSpacing.sm),
        Text('Téléphone : ${profile.phone}'),
        if (profile.isSeller) ...[
          const SizedBox(height: AppSpacing.sm),
          Text('WhatsApp : ${profile.whatsappNumber}'),
        ],
        const SizedBox(height: AppSpacing.xl),
        Text(profile.isSeller
            ? 'Votre compte vendeur est prêt. La gestion des produits arrive '
                'au prochain module.'
            : 'Votre compte client est prêt. Le catalogue et le panier seront '
                'ajoutés dans les prochains modules.'),
        const SizedBox(height: AppSpacing.xl),
        AuthErrorText(message: auth.operationError),
        AppButton(
          label: 'Se déconnecter', variant: AppButtonVariant.secondary,
          isLoading: auth.busy, onPressed: () => auth.signOut(),
        ),
      ],
    );
  }
}
