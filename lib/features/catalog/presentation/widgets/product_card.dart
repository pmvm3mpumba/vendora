import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';

import '../../../../core/models/app_currency.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../models/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  Widget _fallback() => const ColoredBox(
    color: AppColors.secondarySoft,
    child: Icon(
      Icons.image_not_supported_outlined,
      color: AppColors.secondary,
      size: 42,
    ),
  );

  Widget _image() {
    if (product.localImagePath != null) {
      return FutureBuilder<Uint8List>(
        future: XFile(product.localImagePath!).readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(snapshot.data!, fit: BoxFit.cover);
          }
          if (snapshot.hasError) return _fallback();
          return const Center(child: CircularProgressIndicator());
        },
      );
    }
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
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const Center(child: CircularProgressIndicator()),
      );
    }
    return _fallback();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(aspectRatio: 1.15, child: _image()),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${product.priceForDisplay.toStringAsFixed(product.currency == AppCurrency.bif ? 0 : 2)} ${product.currency.code}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    product.isInStock
                        ? '${product.stock} disponible(s)'
                        : 'Rupture de stock',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: product.isInStock
                          ? AppColors.textSecondary
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
