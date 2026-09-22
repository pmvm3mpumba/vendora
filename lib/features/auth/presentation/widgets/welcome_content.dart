import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../catalog/presentation/screens/categories_screen.dart';
import '../../../catalog/presentation/screens/products_screen.dart';
import '../../../catalog/presentation/screens/seller_dashboard_screen.dart';
import '../../../catalog/presentation/widgets/home_catalogue_preview.dart';

/// Pas de produits/ventes fictifs : le catalogue réel arrive au lot suivant.
class WelcomeContent extends StatelessWidget {
  const WelcomeContent({super.key, this.seller = false});
  final bool seller;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final remoteCatalogue = !seller && Firebase.apps.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.hero,
            borderRadius: BorderRadius.circular(AppSpacing.heroRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF31594B),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  seller
                      ? Icons.storefront_outlined
                      : Icons.shopping_bag_outlined,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                seller
                    ? 'Votre boutique,\nvotre nouvel espace.'
                    : 'De belles trouvailles.\nTout simplement.',
                style: text.headlineSmall?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                seller
                    ? 'Votre compte vendeur est prêt. Construisons maintenant votre catalogue.'
                    : 'Découvrez les produits, choisissez votre vendeur et préparez votre prochaine commande.',
                style: text.bodyMedium?.copyWith(
                  color: const Color(0xFFD2E3D8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (remoteCatalogue)
          const HomeCataloguePreview()
        else if (!seller) ...[
          AppButton(
            label: 'Voir les catégories',
            icon: Icons.grid_view_rounded,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const CategoriesScreen()),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Voir le catalogue',
            icon: Icons.storefront_outlined,
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProductsScreen()),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: const AppStateView(
              icon: Icons.storefront_outlined,
              title: 'Le catalogue se prépare',
              message: 'Les catégories et produits Firestore apparaîtront ici lorsque Firebase sera initialisé.',
            ),
          ),
        ] else ...[
          AppButton(
            label: 'Gérer ma boutique',
            icon: Icons.storefront_outlined,
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SellerDashboardScreen(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Voir le catalogue public',
            icon: Icons.storefront_outlined,
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProductsScreen()),
            ),
          ),
        ],
      ],
    );
  }
}
