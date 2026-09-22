import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.secondarySoft,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 44,
                  color: AppColors.secondary,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'Vos commandes apparaîtront ici',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'La consultation des commandes sera activée avec le module checkout et les règles liées aux vendeurs.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
