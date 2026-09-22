import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/models/app_currency.dart';
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
  final _imageUrl = TextEditingController();
  AppCurrency _currency = AppCurrency.bif;
  String _categoryId = 'electronique';
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
    _imageUrl.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? '$label est obligatoire.' : null;

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;
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
        'imageUrl': _imageUrl.text.trim(),
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
                message: 'Les URL HTTPS sont temporaires pour le développement. Le téléversement Firebase Storage sera branché après validation de la solution d’images.',
              ),
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
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _imageUrl,
                label: 'URL HTTPS de l’image',
                keyboardType: TextInputType.url,
                validator: (v) => _required(v, 'L’image'),
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
