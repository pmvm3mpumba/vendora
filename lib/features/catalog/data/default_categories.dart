import '../models/category.dart';

/// Données de présentation uniquement, utilisées lorsque Firestore est encore vide.
/// Elles ne remplacent pas les documents de la collection `categories`.
const localPreviewCategories = <Category>[
  Category(
    id: 'preview-tech',
    name: 'Tech',
    description: 'Les essentiels connectés.',
    iconKey: 'tech',
    sortOrder: 1,
    isActive: true,
  ),
  Category(
    id: 'preview-mode',
    name: 'Mode',
    description: 'Des tenues pour le quotidien.',
    iconKey: 'fashion',
    sortOrder: 2,
    isActive: true,
  ),
  Category(
    id: 'preview-accessoires',
    name: 'Accessoires',
    description: 'Les détails qui font la différence.',
    iconKey: 'accessories',
    sortOrder: 3,
    isActive: true,
  ),
  Category(
    id: 'preview-maison',
    name: 'Maison',
    description: 'Un intérieur qui vous ressemble.',
    iconKey: 'home',
    sortOrder: 4,
    isActive: true,
  ),
];
