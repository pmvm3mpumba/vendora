import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import 'seller_product_form_screen.dart';
import 'seller_products_screen.dart';
import 'seller_orders_screen.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ma boutique')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.hero,
                borderRadius: BorderRadius.circular(AppSpacing.heroRadius),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    color: Colors.white,
                    size: 34,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'Votre boutique,\nvotre nouvel espace.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Ajoutez vos produits et rendez-les visibles dans le catalogue.',
                    style: TextStyle(color: Color(0xFFD2E3D8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Ajouter un produit',
              icon: Icons.add_box_outlined,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SellerProductFormScreen(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Mes produits',
              icon: Icons.inventory_2_outlined,
              variant: AppButtonVariant.secondary,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SellerProductsScreen(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Mes commandes',
              icon: Icons.receipt_long_outlined,
              variant: AppButtonVariant.secondary,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SellerOrdersScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
