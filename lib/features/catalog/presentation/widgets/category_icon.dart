import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Icônes locales des catégories. Aucun téléchargement d'image n'est nécessaire.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.iconKey, this.size = 28});

  final String iconKey;
  final double size;

  static IconData resolve(String key) => switch (key) {
    'tech' => Icons.devices_other_outlined,
    'fashion' => Icons.checkroom_outlined,
    'accessories' => Icons.watch_outlined,
    'home' => Icons.chair_outlined,
    'beauty' => Icons.face_outlined,
    'sport' => Icons.sports_soccer_outlined,
    'baby' => Icons.child_care_outlined,
    'office' => Icons.work_outline,
    'garden' => Icons.local_florist_outlined,
    'food' => Icons.restaurant_outlined,
    'books' => Icons.menu_book_outlined,
    _ => Icons.category_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Icon(resolve(iconKey), size: size, color: AppColors.secondary);
  }
}
