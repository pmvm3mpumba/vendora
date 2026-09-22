import 'package:flutter/foundation.dart';

import '../../catalog/models/product.dart';
import '../models/cart_item.dart';

class CartController extends ChangeNotifier {
  CartController._();
  static final CartController instance = CartController._();

  final List<CartItem> _items = [];
  List<CartItem> get items => List<CartItem>.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.fold(0, (total, item) => total + item.quantity);

  CartItem? itemFor(String productId) {
    for (final item in _items) {
      if (item.product.id == productId) return item;
    }
    return null;
  }

  String? add(Product product, {int quantity = 1}) {
    if (!product.isActive) return 'Ce produit n’est plus disponible.';
    if (product.stock < quantity)
      return 'La quantité demandée dépasse le stock.';
    final existing = itemFor(product.id);
    if (existing == null) {
      _items.add(CartItem(product: product, quantity: quantity));
    } else {
      final next = existing.quantity + quantity;
      if (next > product.stock) return 'La quantité demandée dépasse le stock.';
      _items[_items.indexOf(existing)] = existing.copyWith(quantity: next);
    }
    notifyListeners();
    return null;
  }

  String? increase(Product product) {
    final existing = itemFor(product.id);
    if (existing == null) return add(product);
    if (existing.quantity >= product.stock) return 'Stock maximum atteint.';
    _items[_items.indexOf(existing)] = existing.copyWith(
      quantity: existing.quantity + 1,
    );
    notifyListeners();
    return null;
  }

  void decrease(Product product) {
    final existing = itemFor(product.id);
    if (existing == null) return;
    if (existing.quantity <= 1) {
      remove(product.id);
      return;
    }
    _items[_items.indexOf(existing)] = existing.copyWith(
      quantity: existing.quantity - 1,
    );
    notifyListeners();
  }

  void remove(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
