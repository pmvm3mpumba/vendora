import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../../../core/errors/firebase_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../models/category.dart';
import 'category_icon.dart';

class CategoryListBody extends StatefulWidget {
  const CategoryListBody({
    super.key,
    required this.categories,
    this.localPreviewCategories = const <Category>[],
    required this.onRetry,
    required this.onSelected,
  });
  final Stream<List<Category>> categories;

  /// Aperçu local uniquement quand aucun document Firestore n’existe encore.
  final List<Category> localPreviewCategories;
  final VoidCallback onRetry;
  final ValueChanged<Category> onSelected;

  @override
  State<CategoryListBody> createState() => _CategoryListBodyState();
}

class _CategoryListBodyState extends State<CategoryListBody> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _message(Object error) {
    if (error is FormatException) {
      return 'Une catégorie contient des champs invalides. Vérifiez son document Firestore selon le guide du lot B1.';
    }
    if (error is FirebaseException && error.code == 'permission-denied') {
      return 'La lecture des catégories est refusée. Vérifiez que les règles du lot B1 ont été publiées dans le bon projet Firebase.';
    }
    return firebaseErrorMessage(error);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Category>>(
      stream: widget.categories,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SingleChildScrollView(
            child: AppStateView(
              icon: Icons.cloud_off_outlined,
              title: 'Les catégories sont indisponibles',
              message: _message(snapshot.error!),
              action: AppButton(
                label: 'Réessayer',
                icon: Icons.refresh_rounded,
                onPressed: widget.onRetry,
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              semanticsLabel: 'Chargement des catégories',
            ),
          );
        }
        final firestoreCategories = snapshot.data!;
        final usingLocalPreview =
            firestoreCategories.isEmpty &&
            widget.localPreviewCategories.isNotEmpty;
        final categories = usingLocalPreview
            ? widget.localPreviewCategories
            : firestoreCategories;
        if (categories.isEmpty) {
          return SingleChildScrollView(
            child: AppStateView(
              icon: Icons.category_outlined,
              title: 'Les catégories arrivent bientôt',
              message: 'Aucune catégorie active n’est disponible. Les catégories ajoutées dans Firestore apparaîtront ici.',
              action: AppButton(
                label: 'Actualiser',
                icon: Icons.refresh_rounded,
                onPressed: widget.onRetry,
              ),
            ),
          );
        }
        final filtered = categories
            .where((category) => category.name.toLowerCase().contains(_query))
            .toList();
        final theme = Theme.of(context);
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'À chaque envie, son univers.',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Parcourez les catégories proposées sur Vendora.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (usingLocalPreview) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  ),
                  child: Text(
                    'Aperçu local : ajoutez les catégories dans Firestore pour les rendre réelles.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              AppTextField(
                key: const Key('category_search'),
                label: 'Rechercher une catégorie',
                prefixIcon: Icons.search_rounded,
                controller: _search,
                onChanged: (value) =>
                    setState(() => _query = value.trim().toLowerCase()),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '${filtered.length} catégorie${filtered.length == 1 ? '' : 's'}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              if (filtered.isEmpty)
                AppStateView(
                  icon: Icons.search_off_rounded,
                  title: 'Aucun résultat',
                  message: 'Essayez un autre mot ou effacez votre recherche.',
                  action: AppButton(
                    label: 'Effacer la recherche',
                    variant: AppButtonVariant.secondary,
                    onPressed: () {
                      _search.clear();
                      setState(() => _query = '');
                    },
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final largeText =
                        MediaQuery.textScalerOf(context).scale(16) > 22;
                    final columns = largeText || constraints.maxWidth < 300
                        ? 1
                        : constraints.maxWidth >= 560
                        ? 3
                        : 2;
                    final width =
                        (constraints.maxWidth - (columns - 1) * AppSpacing.md) /
                        columns;
                    return Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: filtered
                          .map(
                            (category) => SizedBox(
                              width: width,
                              child: _CategoryCard(
                                category: category,
                                onTap: () => widget.onSelected(category),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.secondarySoft,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: Text(
                  'Les catégories sont publiques. Un compte sera nécessaire pour commander ou créer des produits.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});
  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Consulter la catégorie ${category.name}',
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('category_${category.id}'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.secondarySoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CategoryIcon(iconKey: category.iconKey),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (category.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    category.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
