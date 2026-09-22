import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/models/app_currency.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/local_image_storage.dart';
import '../../models/product.dart';

class SellerProductEditScreen extends StatefulWidget {
  const SellerProductEditScreen({super.key, required this.product});
  final Product product;

  @override
  State<SellerProductEditScreen> createState() =>
      _SellerProductEditScreenState();
}

class _SellerProductEditScreenState extends State<SellerProductEditScreen> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  late AppCurrency _currency;
  late String _categoryId;
  XFile? _newImage;
  Uint8List? _newImageBytes;
  bool _saving = false;
  String? _error;

  static const categories = <String, String>{
    'electronique': 'Électronique',
    'mode': 'Mode',
    'accessoires': 'Accessoires',
    'maison': 'Maison',
    'beaute': 'Beauté',
    'sport': 'Sport',
    'bebe': 'Bébé',
    'bureau': 'Bureau',
    'jardin': 'Jardin',
    'alimentation': 'Alimentation',
    'livres': 'Livres',
  };

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _name = TextEditingController(text: product.name);
    _description = TextEditingController(text: product.description);
    _price = TextEditingController(text: product.priceForDisplay.toString());
    _stock = TextEditingController(text: product.stock.toString());
    _currency = product.currency;
    _categoryId = product.categoryId;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _chooseImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1400,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() {
      _newImage = image;
      _newImageBytes = bytes;
    });
  }

  Future<void> _save() async {
    final price = double.tryParse(_price.text.trim().replaceAll(',', '.'));
    final stock = int.tryParse(_stock.text.trim());
    if (_name.text.trim().length < 2 || _description.text.trim().isEmpty) {
      setState(() => _error = 'Le nom et la description sont obligatoires.');
      return;
    }
    if (price == null || price <= 0) {
      setState(() => _error = 'Prix invalide.');
      return;
    }
    if (stock == null || stock < 0) {
      setState(() => _error = 'Stock invalide.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      var imageUrl = widget.product.imageUrl;
      var localImagePath = widget.product.localImagePath ?? '';
      if (_newImage != null) {
        final stored = await LocalImageStorage.save(_newImage!);
        imageUrl = '';
        localImagePath = stored.path;
      }
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id)
          .update({
            'name': _name.text.trim(),
            'description': _description.text.trim(),
            'priceMinor': (price * _currency.minorUnitFactor).round(),
            'currency': _currency.code,
            'categoryId': _categoryId,
            'stock': stock,
            'imageUrl': imageUrl,
            'localImagePath': localImagePath,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      if (mounted) Navigator.of(context).pop(true);
    } on FirebaseException catch (error) {
      if (mounted) setState(() => _error = error.message ?? error.code);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le produit')),
      body: Form(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.secondarySoft,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_outlined, color: AppColors.secondary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Modifiez les informations de votre produit.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_newImageBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                child: Image.memory(
                  _newImageBytes!,
                  height: 190,
                  fit: BoxFit.cover,
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _saving ? null : _chooseImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Changer l’image locale'),
              ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(controller: _name, label: 'Nom du produit'),
            const SizedBox(height: AppSpacing.md),
            AppTextField(controller: _description, label: 'Description'),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<AppCurrency>(
              initialValue: _currency,
              decoration: const InputDecoration(labelText: 'Devise'),
              items: AppCurrency.values
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value.code)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _currency = value ?? _currency),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _price,
              label: 'Prix',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _stock,
              label: 'Stock',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _categoryId,
              decoration: const InputDecoration(labelText: 'Catégorie'),
              items: categories.entries
                  .map(
                    (entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _categoryId = value ?? _categoryId),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: _saving
                  ? 'Enregistrement...'
                  : 'Enregistrer les modifications',
              icon: Icons.save_outlined,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
