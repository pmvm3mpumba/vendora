import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/product_repository.dart';
import '../../models/product.dart';
import '../widgets/product_card.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import '../../../cart/state/cart_controller.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.product});
  final Product product;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final theme = Theme.of(context);
    final maxQuantity = product.stock > 0 ? product.stock : 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Le détail qui compte'),
        actions: [
          IconButton(
            tooltip: 'Ouvrir le panier',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const CartScreen())),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Center(child: Text(product.currency.code)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          children: [
            AspectRatio(
              aspectRatio: 1.35,
              child: _ProductImage(product: product),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StockChip(product: product),
                      Text(
                        product.categoryId,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(product.name, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${product.priceForDisplay.toStringAsFixed(product.currency.code == 'BIF' ? 0 : 2)} ${product.currency.code}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(product.description, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.xl),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.secondarySoft,
                        child: Text(
                          product.sellerName.trim().isEmpty
                              ? '?'
                              : product.sellerName.trim()[0].toUpperCase(),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.sellerName,
                              style: theme.textTheme.titleMedium,
                            ),
                            Text('Vendeur', style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.storefront_outlined,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Quantité', style: theme.textTheme.titleMedium),
                  Text(
                    'Maximum $maxQuantity unité(s)',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _QuantityControl(
                    quantity: _quantity,
                    canDecrease: _quantity > 1,
                    canIncrease: _quantity < maxQuantity && product.isInStock,
                    onDecrease: () => setState(() => _quantity--),
                    onIncrease: () => setState(() => _quantity++),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const _DeliveryNotice(),
                  const SizedBox(height: AppSpacing.xl),
                  _ClientCartAction(product: product, quantity: _quantity),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Produits similaires',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SimilarProducts(product: product),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientCartAction extends StatelessWidget {
  const _ClientCartAction({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  Future<bool> _isClient() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return false;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return snapshot.data()?['role'] == 'client';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isClient(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }

        if (snapshot.data != true) {
          return const SizedBox.shrink();
        }

        return AppButton(
          label: product.isInStock ? 'Ajouter au panier' : 'Produit épuisé',
          icon: Icons.shopping_bag_outlined,
          onPressed: product.isInStock
              ? () {
                  final error = CartController.instance.add(
                    product,
                    quantity: quantity,
                  );

                  final message = error ?? 'Produit ajouté au panier.';

                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(message)));
                }
              : null,
        );
      },
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    if (product.imageUrl.startsWith('assets/')) {
      return Image.asset(
        product.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }
    if (product.imageUrl.startsWith('https://')) {
      return Image.network(
        product.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() => const ColoredBox(
    color: AppColors.secondarySoft,
    child: Icon(
      Icons.image_not_supported_outlined,
      size: 56,
      color: AppColors.secondary,
    ),
  );
}

class _StockChip extends StatelessWidget {
  const _StockChip({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: product.isInStock
            ? AppColors.secondarySoft
            : AppColors.errorSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        product.isInStock
            ? '${product.stock} pièces en stock'
            : 'Rupture de stock',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: product.isInStock ? AppColors.secondary : AppColors.error,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.quantity,
    required this.canDecrease,
    required this.canIncrease,
    required this.onDecrease,
    required this.onIncrease,
  });
  final int quantity;
  final bool canDecrease;
  final bool canIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: canDecrease ? onDecrease : null,
              icon: const Icon(Icons.remove),
            ),
            Text('$quantity', style: Theme.of(context).textTheme.titleMedium),
            IconButton(
              onPressed: canIncrease ? onIncrease : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryNotice extends StatelessWidget {
  const _DeliveryNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondarySoft,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined, color: AppColors.secondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Livraison ou retrait gratuit en boutique',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimilarProducts extends StatelessWidget {
  const _SimilarProducts({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: ProductRepository(FirebaseFirestore.instance)
          .watchSimilar(product.categoryId, product.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Les produits similaires sont indisponibles.');
        }
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data!.isEmpty) {
          return const Text('Aucun produit similaire pour le moment.');
        }
        return SizedBox(
          height: 300,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (_, index) => SizedBox(
              width: 190,
              child: ProductCard(product: snapshot.data![index], onTap: () {}),
            ),
          ),
        );
      },
    );
  }
}
