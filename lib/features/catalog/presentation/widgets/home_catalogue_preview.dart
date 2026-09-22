import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/category_repository.dart';
import '../../data/product_repository.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../screens/categories_screen.dart';
import '../screens/product_details_screen.dart';
import 'category_icon.dart';
import 'product_card.dart';

class HomeCataloguePreview extends StatelessWidget {
  const HomeCataloguePreview({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          title: 'À chaque envie, son univers.',
          action: 'Tout voir',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const CategoriesScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 116,
          child: StreamBuilder<List<Category>>(
            stream: CategoryRepository(firestore).watchActive(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.isEmpty) {
                return const Text('Aucune catégorie active.');
              }
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (_, index) =>
                    _CategoryTile(category: snapshot.data![index]),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _SectionTitle(
          title: 'À découvrir',
          action: 'Catalogue',
          onPressed: () {},
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 300,
          child: StreamBuilder<List<Product>>(
            stream: ProductRepository(firestore).watchActive(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.isEmpty) {
                return const Text('Aucun produit disponible.');
              }
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (_, index) {
                  final product = snapshot.data![index];
                  return SizedBox(
                    width: 190,
                    child: ProductCard(
                      product: product,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              ProductDetailsScreen(product: product),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.action,
    required this.onPressed,
  });
  final String title;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        TextButton(onPressed: onPressed, child: Text(action)),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});
  final Category category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CategoryIcon(iconKey: category.iconKey, size: 28),
          const SizedBox(height: AppSpacing.sm),
          Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
