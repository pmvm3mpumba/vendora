import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../data/product_repository.dart';
import '../../models/product.dart';
import '../widgets/product_card.dart';
import 'seller_product_form_screen.dart';

class SellerProductsScreen extends StatelessWidget {
  const SellerProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Connexion vendeur nécessaire.')),
      );
    }
    final source = ProductRepository(FirebaseFirestore.instance);
    return Scaffold(
      appBar: AppBar(title: const Text('Mes produits')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const SellerProductFormScreen(),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
      body: StreamBuilder<List<Product>>(
        stream: source.watchOwned(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'Impossible de charger vos produits. Vérifiez les règles Firestore.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snapshot.data!;
          if (products.isEmpty) {
            return const Center(
              child: Text('Vous n’avez encore aucun produit.'),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              mainAxisExtent: 390,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Stack(
                children: [
                  Positioned.fill(
                    child: ProductCard(product: product, onTap: () {}),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: PopupMenuButton<String>(
                        onSelected: (action) =>
                            _changeProduct(context, product, action),
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'toggle',
                            child: Text(
                              product.isActive ? 'Désactiver' : 'Réactiver',
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Supprimer'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _changeProduct(
    BuildContext context,
    Product product,
    String action,
  ) async {
    final ref = FirebaseFirestore.instance
        .collection('products')
        .doc(product.id);
    try {
      if (action == 'toggle') {
        await ref.update({
          'isActive': !product.isActive,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else if (action == 'delete') {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Supprimer le produit ?'),
            content: Text('Cette action concerne « ${product.name} ».'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        );
        if (confirmed == true) await ref.delete();
      }
    } on FirebaseException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Action refusée : ${error.message ?? error.code}'),
          ),
        );
      }
    }
  }
}
