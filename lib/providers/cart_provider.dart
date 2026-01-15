import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';

/// Cart Item Model
class CartItem {
  final ProductModel product;
  final int quantity;

  CartItem({required this.product, this.quantity = 1});

  CartItem copyWith({ProductModel? product, int? quantity}) {
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
  final String? reportOrderNumber;
  final String? deviceName;

  CartState({List<CartItem>? items, this.reportOrderNumber, this.deviceName})
    : items = items ?? [];

  CartState copyWith({
    List<CartItem>? items,
    String? reportOrderNumber,
    String? deviceName,
  }) {
    return CartState(
      items: items ?? this.items,
      reportOrderNumber: reportOrderNumber ?? this.reportOrderNumber,
      deviceName: deviceName ?? this.deviceName,
    );
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}

/// Cart Notifier
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  /// Add product to cart
  void addToCart(
    ProductModel product, {
    String? reportOrderNumber,
    String? deviceName,
  }) {
    final existingIndex = state.items.indexWhere(
      (item) => item.product.id == product.id,
    );

    List<CartItem> updatedItems;
    if (existingIndex >= 0) {
      // Increase quantity if product already in cart
      final existingItem = state.items[existingIndex];
      updatedItems = List<CartItem>.from(state.items);
      updatedItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
      );
    } else {
      // Add new item to cart
      updatedItems = [...state.items, CartItem(product: product)];
    }

    state = state.copyWith(
      items: updatedItems,
      reportOrderNumber: reportOrderNumber ?? state.reportOrderNumber,
      deviceName: deviceName ?? state.deviceName,
    );
  }

  /// Remove product from cart
  void removeFromCart(String productId) {
    state = state.copyWith(
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

    state = state.copyWith(items: updatedItems);
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
      orElse: () => CartItem(
        product: ProductModel(id: '', name: '', description: '', imageUrl: ''),
      ),
    );
    return item.quantity;
  }
}

/// Cart Provider
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
