import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';

/// Cart Item Model
class CartItem {
  final ProductModel product;
  final int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  CartItem copyWith({
    ProductModel? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  double get totalPrice => (product.price ?? 0) * quantity;
}

/// Cart State
class CartState {
  final List<CartItem> items;

  CartState({List<CartItem>? items}) : items = items ?? [];

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  
  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}

/// Cart Notifier
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  /// Add product to cart
  void addToCart(ProductModel product) {
    final existingIndex = state.items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // Increase quantity if product already in cart
      final existingItem = state.items[existingIndex];
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
      );
      state = CartState(items: updatedItems);
    } else {
      // Add new item to cart
      state = CartState(
        items: [...state.items, CartItem(product: product)],
      );
    }
  }

  /// Remove product from cart
  void removeFromCart(String productId) {
    state = CartState(
      items: state.items.where((item) => item.product.id != productId).toList(),
    );
  }

  /// Update quantity
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = CartState(items: updatedItems);
  }

  /// Clear cart
  void clearCart() {
    state = CartState();
  }

  /// Check if product is in cart
  bool isInCart(String productId) {
    return state.items.any((item) => item.product.id == productId);
  }

  /// Get quantity of product in cart
  int getQuantity(String productId) {
    final item = state.items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(product: ProductModel(id: '', name: '', description: '', imageUrl: '')),
    );
    return item.quantity;
  }
}

/// Cart Provider
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

