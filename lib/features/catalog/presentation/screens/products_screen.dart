import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../data/product_repository.dart';
import '../../models/product.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key, this.source});
  final ProductSource? source;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late final ProductSource _source;
  late Stream<List<Product>> _products;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _source = widget.source ?? ProductRepository(FirebaseFirestore.instance);
    _products = _source.watchActive();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catalogue')),
      body: StreamBuilder<List<Product>>(
        stream: _products,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'Impossible de charger les produits. Vérifiez Firestore et réessayez.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snapshot.data!
              .where((product) => product.name.toLowerCase().contains(_query))
              .toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Rechercher un produit',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onChanged: (value) =>
                      setState(() => _query = value.trim().toLowerCase()),
                ),
              ),
              Expanded(
                child: products.isEmpty
                    ? Center(
                        child: Text(
                          snapshot.data!.isEmpty
                              ? 'Aucun produit disponible.'
                              : 'Aucun résultat.',
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.xl,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 280,
                              mainAxisExtent: 350,
                              crossAxisSpacing: AppSpacing.md,
                              mainAxisSpacing: AppSpacing.md,
                            ),
                        itemCount: products.length,
                        itemBuilder: (_, index) => ProductCard(
                          product: products[index],
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ProductDetailsScreen(
                                product: products[index],
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
