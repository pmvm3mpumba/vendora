import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/widgets/app_button.dart';
import '../core/widgets/app_state_view.dart';
import '../core/widgets/app_text_field.dart';

/// Écran temporaire pour valider le design system, pas le vrai catalogue.
class FoundationScreen extends StatelessWidget {
  const FoundationScreen({super.key});

  void _showStatus(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Thème prêt. Firebase sera connecté à la prochaine étape.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
            SizedBox(width: AppSpacing.sm),
            Text('Exam Shop'),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      avatar: Icon(Icons.construction_outlined, size: 18),
                      label: Text('Aperçu de développement'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Votre boutique, à portée de main.',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Une base commune pour une expérience simple et cohérente.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const AppTextField(
                    label: 'Rechercher un produit',
                    hint: 'Disponible après la connexion au catalogue',
                    prefixIcon: Icons.search,
                    enabled: false,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.cardRadius,
                      ),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: const AppStateView(
                      icon: Icons.storefront_outlined,
                      title: 'Les fondations sont prêtes',
                      message:
                          'Cet écran vérifie les couleurs, les textes et les '
                          'composants. Aucun produit ni compte Firebase '
                          'n’est encore chargé.',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: 'Tester le bouton principal',
                    onPressed: () => _showStatus(context),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Voir les prochaines étapes',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('La suite du projet'),
                        content: const SingleChildScrollView(
                          child: Text(
                            '1. Connecter Firebase.\n'
                            '2. Créer les comptes client et vendeur.\n'
                            '3. Construire les produits et le catalogue.',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Fermer'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Android comme cible finale • Chrome pour les tests',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
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
