import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/models/app_currency.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_notice.dart';
import '../../../../core/widgets/app_text_field.dart';

class SellerProductFormScreen extends StatefulWidget {
  const SellerProductFormScreen({super.key});

  @override
  State<SellerProductFormScreen> createState() =>
      _SellerProductFormScreenState();
}

class _SellerProductFormScreenState extends State<SellerProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();

  AppCurrency _currency = AppCurrency.bif;
  String _categoryId = 'electronique';
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _saving = false;
  String? _error;

  static const _categories = <String, String>{
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
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label est obligatoire.';
    }
    return null;
  }

  Future<void> _pickImage() async {
    if (_saving) return;
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1400,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() {
      _selectedImage = image;
      _selectedImageBytes = bytes;
    });
  }

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      setState(() => _error = 'Choisissez une image pour le produit.');
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _error = 'Connectez-vous avec un compte vendeur.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final profile = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = profile.data();
      if (!profile.exists || data?['role'] != 'seller') {
        throw StateError('Ce compte n’est pas un vendeur.');
      }
      final priceValue = double.tryParse(
        _price.text.trim().replaceAll(',', '.'),
      );
      final stock = int.tryParse(_stock.text.trim());
      if (priceValue == null || priceValue <= 0) {
        throw const FormatException('Prix invalide.');
      }
      if (stock == null || stock < 0) {
        throw const FormatException('Stock invalide.');
      }
      final priceMinor = (priceValue * _currency.minorUnitFactor).round();
      await FirebaseFirestore.instance.collection('products').add({
        'name': _name.text.trim(),
        'description': _description.text.trim(),
        'priceMinor': priceMinor,
        'currency': _currency.code,
        'categoryId': _categoryId,
        'stock': stock,
        'imageUrl': '',
        'localImagePath': _selectedImage!.path,
        'sellerId': user.uid,
        'sellerName':
            (data?['name'] as String?)?.trim() ?? user.email ?? 'Vendeur',
        'sellerWhatsappNumber': data?['whatsappNumber'] ?? '',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _imagePickerCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Image du produit', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Choisissez une image depuis votre appareil.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          AspectRatio(
            aspectRatio: 1.35,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
              child: _selectedImageBytes == null
                  ? InkWell(
                      onTap: _pickImage,
                      child: const ColoredBox(
                        color: AppColors.secondarySoft,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 42,
                              color: AppColors.secondary,
                            ),
                            SizedBox(height: 10),
                            Text('Ajouter une image'),
                          ],
                        ),
                      ),
                    )
                  : Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: _saving ? null : _pickImage,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(
              _selectedImage == null ? 'Choisir une image' : 'Changer l’image',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Stockage local temporaire. Une URL publique sera ajoutée lorsque l’hébergement sera validé.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un produit')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const AppNotice(
                message: 'L’image est conservée localement pour le moment. Elle ne sera pas encore visible sur les autres appareils.',
              ),
              const SizedBox(height: AppSpacing.lg),
              _imagePickerCard(context),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _name,
                label: 'Nom du produit',
                validator: (v) => _required(v, 'Le nom'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _description,
                label: 'Description',
                validator: (v) => _required(v, 'La description'),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<AppCurrency>(
                initialValue: _currency,
                decoration: const InputDecoration(labelText: 'Devise'),
                items: AppCurrency.values
                    .map(
                      (currency) => DropdownMenuItem(
                        value: currency,
                        child: Text(currency.code),
                      ),
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
                validator: (v) => _required(v, 'Le prix'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _stock,
                label: 'Stock disponible',
                keyboardType: TextInputType.number,
                validator: (v) => _required(v, 'Le stock'),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _categoryId,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                items: _categories.entries
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
                label: _saving ? 'Enregistrement...' : 'Enregistrer le produit',
                icon: Icons.save_outlined,
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
