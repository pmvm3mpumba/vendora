import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../data/category_repository.dart';
import '../../data/default_categories.dart';
import '../../models/category.dart';
import '../widgets/category_icon.dart';
import '../widgets/category_list_body.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key, this.source});

  /// Injection utilisée uniquement pour les tests. Par défaut : vraie base Firestore.
  final CategorySource? source;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late final CategorySource _source;
  late Stream<List<Category>> _categories;

  @override
  void initState() {
    super.initState();
    _source = widget.source ?? CategoryRepository(FirebaseFirestore.instance);
    _categories = _source.watchActive();
  }

  void _retry() => setState(() => _categories = _source.watchActive());

  void _showCategory(Category category) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (context) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: CategoryIcon(iconKey: category.iconKey, size: 36),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              category.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (category.description.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                category.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            const AppNotice(
              message:
                  'Cette catégorie est enregistrée dans Firestore. '
                  'La liste de ses produits sera ajoutée au prochain module.',
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Retour aux catégories',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catégories')),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.pageMaxWidth,
            ),
            child: CategoryListBody(
              categories: _categories,
              localPreviewCategories: widget.source == null
                  ? localPreviewCategories
                  : const <Category>[],
              onRetry: _retry,
              onSelected: _showCategory,
            ),
          ),
        ),
      ),
    );
  }
}
