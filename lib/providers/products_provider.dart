import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../services/woocommerce_service.dart';
import '../utils/constants.dart';

/// WooCommerce Service Provider
///
/// Provides access to the WooCommerce service with API credentials
final wooCommerceServiceProvider = Provider<WooCommerceService>((ref) {
  // WooCommerce API credentials from constants
  return WooCommerceService(
    consumerKey: AppConstants.wooCommerceConsumerKey,
    consumerSecret: AppConstants.wooCommerceConsumerSecret,
  );
});

/// Products Provider
///
/// Fetches products from WooCommerce API
/// This provider can be used to get all products or filter by category
final productsProvider = FutureProvider.autoDispose<List<ProductModel>>((
  ref,
) async {
  final wooCommerceService = ref.read(wooCommerceServiceProvider);

  try {
    developer.log('🛒 Fetching products from WooCommerce...', name: 'Products');

    final products = await wooCommerceService.getProducts(
      perPage: 100, // Get up to 100 products
    );

    developer.log(
      '✅ Successfully fetched ${products.length} products',
      name: 'Products',
    );

    return products;
  } catch (e, stackTrace) {
    developer.log('❌ Error fetching products: $e', name: 'Products');
    developer.log('   Stack trace: $stackTrace', name: 'Products');
    rethrow;
  }
});

/// Care Products Provider
///
/// Fetches care-related products from WooCommerce
/// Filtered by "Accessories" category
final careProductsProvider = FutureProvider.autoDispose<List<ProductModel>>((
  ref,
) async {
  final wooCommerceService = ref.read(wooCommerceServiceProvider);

  try {
    developer.log(
      '🛒 [Products] ========================================',
      name: 'Products',
    );
    developer.log(
      '🛒 [Products] Starting to fetch care products from WooCommerce',
      name: 'Products',
    );
    developer.log(
      '🛒 [Products] Category: "Accessories" (slug: "accessories")',
      name: 'Products',
    );
    developer.log(
      '🛒 [Products] ========================================',
      name: 'Products',
    );

    // Filter products by "Accessories" category slug
    final products = await wooCommerceService.getProducts(
      perPage: 100,
      categorySlug: 'accessories',
    );

    developer.log(
      '✅ [Products] ========================================',
      name: 'Products',
    );
    developer.log(
      '✅ [Products] Successfully fetched ${products.length} care products from Accessories category',
      name: 'Products',
    );
    if (products.isEmpty) {
      developer.log(
        '⚠️ [Products] WARNING: No products found! Check category slug and API connection.',
        name: 'Products',
      );
    } else {
      developer.log('📦 [Products] Products found:', name: 'Products');
      for (int i = 0; i < products.length; i++) {
        final product = products[i];
        developer.log(
          '  ${i + 1}. ID: ${product.id}, Name: "${product.name}", Price: ${product.price ?? "N/A"}',
          name: 'Products',
        );
      }
    }
    developer.log(
      '✅ [Products] ========================================',
      name: 'Products',
    );

    return products;
  } catch (e, stackTrace) {
    developer.log(
      '❌ [Products] ========================================',
      name: 'Products',
    );
    developer.log(
      '❌ [Products] ERROR fetching care products: $e',
      name: 'Products',
    );
    developer.log('📚 [Products] Stack trace: $stackTrace', name: 'Products');
    developer.log(
      '❌ [Products] ========================================',
      name: 'Products',
    );
    rethrow;
  }
});
