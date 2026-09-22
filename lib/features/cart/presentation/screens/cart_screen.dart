import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../models/cart_item.dart';
import '../../state/cart_controller.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartController.instance,
      builder: (context, _) {
        final cart = CartController.instance;
        return Scaffold(
          appBar: AppBar(title: const Text('Panier')),
          body: cart.isEmpty
              ? const _EmptyCart()
              : _CartBody(items: cart.items),
        );
      },
    );
  }
}

class _CartBody extends StatelessWidget {
  const _CartBody({required this.items});
  final List<CartItem> items;

  @override
  Widget build(BuildContext context) {
    final totals = <String, int>{};
    for (final item in items) {
      final code = item.product.currency.code;
      totals[code] = (totals[code] ?? 0) + item.lineTotalMinor;
    }
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          '${items.length} article(s)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _CartItemTile(item: item),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Sous-total',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              ...totals.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    '${_display(entry.value, entry.key)} ${entry.key}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'La livraison et le choix de devise seront confirmés au checkout.',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Text('Continuer vers le checkout'),
        ),
      ],
    );
  }

  String _display(int minor, String code) =>
      code == 'BIF' ? '$minor' : (minor / 100).toStringAsFixed(2);
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;
    final product = item.product;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.secondarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.priceForDisplay.toStringAsFixed(product.currency.code == 'BIF' ? 0 : 2)} ${product.currency.code}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => cart.decrease(product),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('${item.quantity}'),
                    IconButton(
                      onPressed: () => cart.increase(product),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => cart.remove(product.id),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 56,
              color: AppColors.secondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Votre panier est vide',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Ajoutez un produit pour commencer votre commande.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
