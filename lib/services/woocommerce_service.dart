import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../utils/constants.dart';

/// WooCommerce API Service
///
/// Service to interact with WooCommerce REST API
class WooCommerceService {
  /// Base URL for WooCommerce API
  static String get baseUrl => AppConstants.wooCommerceBaseUrl;

  /// Consumer Key for WooCommerce API authentication
  final String consumerKey;

  /// Consumer Secret for WooCommerce API authentication
  final String consumerSecret;

  /// API version
  static const String apiVersion = 'v3';

  /// Constructor
  WooCommerceService({required this.consumerKey, required this.consumerSecret});

  /// Get the full API endpoint URL
  String _getApiUrl(String endpoint) {
    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '$cleanBaseUrl/wp-json/wc/$apiVersion$cleanEndpoint';
  }

  /// Create Basic Auth header
  String _getBasicAuth() {
    final credentials = '$consumerKey:$consumerSecret';
    final bytes = utf8.encode(credentials);
    final base64Str = base64Encode(bytes);
    return 'Basic $base64Str';
  }

  /// Make HTTP request to WooCommerce API
  Future<Map<String, dynamic>> _makeRequest(
    String endpoint, {
    Map<String, String>? queryParams,
    int maxRetries = 3,
  }) async {
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        var url = Uri.parse(_getApiUrl(endpoint));

        // Add query parameters
        if (queryParams != null && queryParams.isNotEmpty) {
          url = url.replace(queryParameters: queryParams);
        }

        developer.log(
          'Making WooCommerce API request: ${url.toString()}',
          name: 'WooCommerce',
        );

        final response = await http
            .get(
              url,
              headers: {
                'Authorization': _getBasicAuth(),
                'Content-Type': 'application/json',
              },
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                throw WooCommerceException(
                  message: 'Request timeout',
                  statusCode: 408,
                );
              },
            );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          if (response.body.isEmpty) {
            return <String, dynamic>{};
          }

          try {
            final decoded = jsonDecode(response.body);

            if (decoded is Map<String, dynamic>) {
              return decoded;
            } else if (decoded is List) {
              return {'data': decoded};
            } else {
              return {'data': decoded};
            }
          } catch (e) {
            developer.log(
              'WooCommerce API Response Error - Status: ${response.statusCode}',
              name: 'WooCommerce',
            );
            developer.log(
              'Response body: ${response.body}',
              name: 'WooCommerce',
            );
            throw WooCommerceException(
              message: 'Invalid response format: ${e.toString()}',
              statusCode: response.statusCode,
            );
          }
        } else {
          try {
            final errorData = jsonDecode(response.body) as Map<String, dynamic>;
            throw WooCommerceException(
              message:
                  errorData['message']?.toString() ??
                  'API request failed with status ${response.statusCode}',
              statusCode: response.statusCode,
              errorCode: errorData['code']?.toString(),
            );
          } catch (e) {
            throw WooCommerceException(
              message: 'API request failed with status ${response.statusCode}',
              statusCode: response.statusCode,
            );
          }
        }
      } on WooCommerceException {
        rethrow;
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          developer.log(
            'WooCommerce API request failed after $maxRetries attempts: $e',
            name: 'WooCommerce',
          );
          throw WooCommerceException(
            message: 'Network error: ${e.toString()}',
            statusCode: 0,
          );
        }

        // Exponential backoff
        final delaySeconds = 1 << (attempt - 1);
        final delay = Duration(seconds: delaySeconds > 10 ? 10 : delaySeconds);
        await Future.delayed(delay);
      }
    }

    throw WooCommerceException(
      message: 'Request failed after $maxRetries attempts',
      statusCode: 0,
    );
  }

  /// Get all categories (for debugging)
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      developer.log(
        '📋 [WooCommerce] Fetching all categories...',
        name: 'WooCommerce',
      );

      final response = await _makeRequest(
        '/products/categories',
        queryParams: {'per_page': '100'},
      );

      List categoriesData;
      if (response['data'] != null) {
        final data = response['data'];
        if (data is List) {
          categoriesData = data;
        } else {
          categoriesData = [];
        }
      } else {
        categoriesData = [];
      }

      developer.log(
        '✅ [WooCommerce] Successfully fetched ${categoriesData.length} categories',
        name: 'WooCommerce',
      );

      return categoriesData.map((cat) => cat as Map<String, dynamic>).toList();
    } catch (e) {
      developer.log(
        '❌ [WooCommerce] Error fetching all categories: $e',
        name: 'WooCommerce',
      );
      return [];
    }
  }

  /// Get category ID by slug
  ///
  /// [slug] - Category slug
  /// Returns the category ID if found, null otherwise
  Future<int?> getCategoryIdBySlug(String slug) async {
    try {
      developer.log(
        '🔍 [WooCommerce] Looking up category ID for slug: "$slug"',
        name: 'WooCommerce',
      );

      // First try with slug parameter
      final url = _getApiUrl('/products/categories');
      developer.log(
        '🌐 [WooCommerce] API URL: $url?slug=$slug',
        name: 'WooCommerce',
      );

      try {
        developer.log(
          '📡 [WooCommerce] Attempting direct slug lookup...',
          name: 'WooCommerce',
        );

        final response = await _makeRequest(
          '/products/categories',
          queryParams: {'slug': slug},
        );

        developer.log(
          '📦 [WooCommerce] Category API response received',
          name: 'WooCommerce',
        );

        // WooCommerce API returns categories - check if wrapped in 'data' key
        List categoriesData;
        if (response['data'] != null) {
          final data = response['data'];
          if (data is List) {
            categoriesData = data;
          } else {
            categoriesData = [];
          }
        } else {
          categoriesData = [];
        }

        developer.log(
          '📊 [WooCommerce] Found ${categoriesData.length} categories matching slug "$slug"',
          name: 'WooCommerce',
        );

        if (categoriesData.isNotEmpty) {
          final category = categoriesData.first as Map<String, dynamic>;
          final categoryId = category['id'];
          final categoryName = category['name']?.toString() ?? 'Unknown';

          developer.log(
            '✅ [WooCommerce] Category found! ID: $categoryId, Name: "$categoryName", Slug: "$slug"',
            name: 'WooCommerce',
          );
          return categoryId is int
              ? categoryId
              : int.tryParse(categoryId.toString());
        }

        developer.log(
          '⚠️ [WooCommerce] No categories found with direct slug lookup',
          name: 'WooCommerce',
        );
      } catch (e) {
        developer.log(
          '❌ [WooCommerce] Direct slug lookup failed: $e',
          name: 'WooCommerce',
        );
        developer.log(
          '🔄 [WooCommerce] Falling back to fetch all categories...',
          name: 'WooCommerce',
        );
      }

      // Fallback: fetch all categories and search for the slug
      developer.log(
        '📋 [WooCommerce] Fetching all categories to search for slug "$slug"',
        name: 'WooCommerce',
      );
      final allCategories = await getAllCategories();

      developer.log(
        '🔎 [WooCommerce] Searching through ${allCategories.length} categories...',
        name: 'WooCommerce',
      );

      for (final category in allCategories) {
        final categorySlug = category['slug']?.toString();
        final categoryName = category['name']?.toString() ?? 'Unknown';
        final categoryId = category['id'];

        developer.log(
          '  - Checking: ID=$categoryId, Name="$categoryName", Slug="$categorySlug"',
          name: 'WooCommerce',
        );

        if (categorySlug == slug) {
          developer.log(
            '✅ [WooCommerce] MATCH FOUND! Category ID: $categoryId, Name: "$categoryName", Slug: "$categorySlug"',
            name: 'WooCommerce',
          );
          return categoryId is int
              ? categoryId
              : int.tryParse(categoryId.toString());
        }
      }

      developer.log(
        '❌ [WooCommerce] Category with slug "$slug" not found in ${allCategories.length} categories',
        name: 'WooCommerce',
      );

      // Log all available category slugs for debugging
      if (allCategories.isNotEmpty) {
        final slugs = allCategories
            .map((c) => c['slug']?.toString() ?? 'null')
            .toList();
        final names = allCategories
            .map((c) => c['name']?.toString() ?? 'null')
            .toList();

        developer.log(
          '📝 [WooCommerce] Available categories (${allCategories.length} total):',
          name: 'WooCommerce',
        );
        for (int i = 0; i < allCategories.length; i++) {
          final cat = allCategories[i];
          developer.log(
            '  ${i + 1}. ID: ${cat['id']}, Name: "${names[i]}", Slug: "${slugs[i]}"',
            name: 'WooCommerce',
          );
        }
      } else {
        developer.log(
          '⚠️ [WooCommerce] No categories available in the store',
          name: 'WooCommerce',
        );
      }

      return null;
    } catch (e, stackTrace) {
      developer.log(
        '❌ [WooCommerce] Error fetching category by slug "$slug": $e',
        name: 'WooCommerce',
      );
      developer.log(
        '📚 [WooCommerce] Stack trace: $stackTrace',
        name: 'WooCommerce',
      );
      return null;
    }
  }

  /// Get products from WooCommerce
  ///
  /// [category] - Optional category ID to filter products
  /// [categorySlug] - Optional category slug to filter products (will be converted to ID, or filtered client-side)
  /// [perPage] - Number of products per page (default: 100)
  /// [page] - Page number (default: 1)
  Future<List<ProductModel>> getProducts({
    int? category,
    String? categorySlug,
    int perPage = 100,
    int page = 1,
  }) async {
    try {
      // If categorySlug is provided, first try to get the category ID
      int? categoryId = category;
      bool useClientSideFilter = false;

      if (categorySlug != null && categoryId == null) {
        developer.log(
          '🔍 [WooCommerce] Looking up category ID for slug: "$categorySlug"',
          name: 'WooCommerce',
        );
        categoryId = await getCategoryIdBySlug(categorySlug);

        if (categoryId == null) {
          developer.log(
            '⚠️ [WooCommerce] Category with slug "$categorySlug" not found via API, will filter client-side',
            name: 'WooCommerce',
          );
          useClientSideFilter = true;
        } else {
          developer.log(
            '✅ [WooCommerce] Found category ID $categoryId for slug "$categorySlug"',
            name: 'WooCommerce',
          );
        }
      }

      final queryParams = <String, String>{
        'per_page': perPage.toString(),
        'page': page.toString(),
        'status': 'publish', // Only get published products
      };

      // Only use category filter if we have an ID and not using client-side filter
      if (categoryId != null && !useClientSideFilter) {
        queryParams['category'] = categoryId.toString();
      }

      final response = await _makeRequest(
        '/products',
        queryParams: queryParams,
      );

      final productsData = response['data'] as List? ?? response as List;

      // If we need to filter by slug client-side, do it before conversion
      List<dynamic> filteredProductsData = productsData;
      if (useClientSideFilter && categorySlug != null) {
        developer.log(
          '🔄 [WooCommerce] Filtering ${productsData.length} products by category slug "$categorySlug"',
          name: 'WooCommerce',
        );

        filteredProductsData = productsData.where((productJson) {
          if (productJson is! Map<String, dynamic>) return false;

          // Check if product belongs to the category by examining categories array
          if (productJson['categories'] != null) {
            final categories = productJson['categories'] as List;
            return categories.any((cat) {
              if (cat is Map<String, dynamic>) {
                final catSlug = cat['slug']?.toString();
                final catName = cat['name']?.toString() ?? 'Unknown';
                final matches = catSlug == categorySlug;
                if (matches) {
                  developer.log(
                    '  ✅ Product "${productJson['name']}" belongs to category "$catName" (slug: "$catSlug")',
                    name: 'WooCommerce',
                  );
                }
                return matches;
              }
              return false;
            });
          }
          return false;
        }).toList();

        developer.log(
          '✅ [WooCommerce] Filtered to ${filteredProductsData.length} products in category "$categorySlug"',
          name: 'WooCommerce',
        );
      }

      // Convert to ProductModel list
      return filteredProductsData.map((productJson) {
        return ProductModel.fromWooCommerceJson(
          productJson as Map<String, dynamic>,
        );
      }).toList();
    } catch (e) {
      developer.log('Error fetching products: $e', name: 'WooCommerce');
      rethrow;
    }
  }

  /// Get a single product by ID
  Future<ProductModel> getProduct(int productId) async {
    try {
      final response = await _makeRequest('/products/$productId');

      final productData = response['data'] ?? response;

      return ProductModel.fromWooCommerceJson(
        productData as Map<String, dynamic>,
      );
    } catch (e) {
      developer.log(
        'Error fetching product $productId: $e',
        name: 'WooCommerce',
      );
      rethrow;
    }
  }

  /// Create an order in WooCommerce
  ///
  /// [customerData] - Customer information (name, email, phone, address)
  /// [lineItems] - List of products with quantities
  /// Returns the created order data
  Future<Map<String, dynamic>> createOrder({
    required Map<String, dynamic> customerData,
    required List<Map<String, dynamic>> lineItems,
  }) async {
    try {
      developer.log('🛒 [WooCommerce] Creating order...', name: 'WooCommerce');
      developer.log(
        '   Customer: ${customerData['first_name']} ${customerData['last_name'] ?? ''}',
        name: 'WooCommerce',
      );
      developer.log('   Items: ${lineItems.length}', name: 'WooCommerce');

      final orderData = {
        'payment_method': 'bacs', // Bank transfer
        'payment_method_title': 'تحويل بنكي',
        'set_paid': false, // Order will be pending payment
        'status': 'processing', // Order processing
        'created_via': 'laapak_mobile_app', // Track source
        'meta_data': [
          {'key': '_created_via', 'value': 'laapak_mobile_app'},
        ],
        'billing': {
          'first_name': customerData['first_name'] ?? '',
          'last_name': customerData['last_name'] ?? '',
          'email': customerData['email'] ?? '',
          'phone': customerData['phone'] ?? '',
          'address_1': customerData['address_1'] ?? '',
          'address_2': customerData['address_2'] ?? '',
          'city': customerData['city'] ?? '',
          'state': customerData['state'] ?? '',
          'postcode': customerData['postcode'] ?? '',
          'country': customerData['country'] ?? 'EG', // Default to Egypt
        },
        'shipping': {
          'first_name': customerData['first_name'] ?? '',
          'last_name': customerData['last_name'] ?? '',
          'address_1': customerData['address_1'] ?? '',
          'address_2': customerData['address_2'] ?? '',
          'city': customerData['city'] ?? '',
          'state': customerData['state'] ?? '',
          'postcode': customerData['postcode'] ?? '',
          'country': customerData['country'] ?? 'EG',
        },
        'line_items': lineItems,
        'customer_note': customerData['note'] ?? '',
      };

      // Make POST request to create order
      final url = Uri.parse(_getApiUrl('/orders'));
      developer.log(
        'Making WooCommerce POST request: ${url.toString()}',
        name: 'WooCommerce',
      );

      final httpResponse = await http
          .post(
            url,
            headers: {
              'Authorization': _getBasicAuth(),
              'Content-Type': 'application/json',
              'User-Agent': 'WooCommerce-REST-API-Client/3.0',
            },
            body: jsonEncode(orderData),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw WooCommerceException(
                message: 'Request timeout',
                statusCode: 408,
              );
            },
          );

      if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
        final decoded = jsonDecode(httpResponse.body) as Map<String, dynamic>;
        developer.log(
          '✅ [WooCommerce] Order created successfully! ID: ${decoded['id']}',
          name: 'WooCommerce',
        );
        return decoded;
      } else {
        final errorData = jsonDecode(httpResponse.body) as Map<String, dynamic>;
        throw WooCommerceException(
          message:
              errorData['message']?.toString() ??
              'API request failed with status ${httpResponse.statusCode}',
          statusCode: httpResponse.statusCode,
          errorCode: errorData['code']?.toString(),
        );
      }
    } catch (e) {
      developer.log(
        '❌ [WooCommerce] Error creating order: $e',
        name: 'WooCommerce',
      );
      rethrow;
    }
  }
}

/// WooCommerce API Exception
class WooCommerceException implements Exception {
  final String message;
  final int statusCode;
  final String? errorCode;

  WooCommerceException({
    required this.message,
    required this.statusCode,
    this.errorCode,
  });

  @override
  String toString() {
    if (errorCode != null) {
      return 'WooCommerceException [$statusCode] ($errorCode): $message';
    }
    return 'WooCommerceException [$statusCode]: $message';
  }
}
