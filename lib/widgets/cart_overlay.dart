import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/cached_image.dart';
import '../widgets/empty_state.dart';

/// Global Cart Overlay
///
/// Shows a cart summary bar at the bottom of the screen if items are in the cart.
class CartOverlay extends ConsumerWidget {
  final Widget child;

  const CartOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          // Main app content
          Padding(
            padding: EdgeInsets.only(
              bottom: cartState.isNotEmpty ? 100.0 : 0.0,
            ),
            child: child,
          ),

          // Cart bottom bar overlay
          if (cartState.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildCartBottomBar(context, ref, cartState),
            ),
        ],
      ),
    );
  }

  Widget _buildCartBottomBar(
    BuildContext context,
    WidgetRef ref,
    CartState cartState,
  ) {
    return GestureDetector(
      onTap: () => _showCartBottomSheet(context),
      child: Container(
        padding: Responsive.screenPadding,
        decoration: BoxDecoration(
          color: LaapakColors.surface,
          border: Border(top: BorderSide(color: LaapakColors.borderLight)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Cancel button (X icon)
              IconButton(
                icon: Icon(Icons.close, color: LaapakColors.textSecondary),
                onPressed: () {
                  ref.read(cartProvider.notifier).clearCart();
                },
              ),
              SizedBox(width: Responsive.sm),

              // Cart info (clickable area)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${cartState.itemCount} منتج في السلة',
                      style: LaapakTypography.titleSmall(
                        color: LaapakColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: Responsive.xs),
                    Text(
                      'الإجمالي: ${cartState.totalPrice.toStringAsFixed(0)} ج.م',
                      style: LaapakTypography.bodyMedium(
                        color: LaapakColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: Responsive.md),

              // Confirm order button
              ElevatedButton(
                onPressed: () => _confirmOrder(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: LaapakColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.md,
                    vertical: Responsive.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'تأكيد الطلب',
                  style: LaapakTypography.bodyMedium(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CartBottomSheet(),
    );
  }

  Future<void> _confirmOrder(BuildContext context, WidgetRef ref) async {
    final cartState = ref.read(cartProvider);
    final authState = ref.read(authProvider);
    final wooCommerceService = ref.read(wooCommerceServiceProvider);

    if (cartState.isEmpty) return;

    if (authState.client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى تسجيل الدخول أولاً',
            style: LaapakTypography.bodyMedium(color: LaapakColors.background),
          ),
          backgroundColor: LaapakColors.error,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: Responsive.cardPaddingInsets,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: LaapakColors.primary),
                SizedBox(height: Responsive.md),
                Text(
                  'جارٍ إنشاء الطلب...',
                  style: LaapakTypography.bodyMedium(
                    color: LaapakColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final client = authState.client!;

      final customerData = {
        'first_name': client.name.split(' ').first,
        'last_name': client.name.split(' ').length > 1
            ? client.name.split(' ').skip(1).join(' ')
            : '',
        'email': client.email ?? 'customer@laapak.com',
        'phone': client.phone,
        'address_1': client.address ?? 'Cairo',
        'city': 'Cairo',
        'state': 'Cairo',
        'postcode': '11511',
        'country': 'EG',
        'note':
            'Order Code: ${client.orderCode}'
            '${cartState.reportOrderNumber != null ? '\nReport Order #: ${cartState.reportOrderNumber}' : ''}'
            '${cartState.deviceName != null ? '\nDevice: ${cartState.deviceName}' : ''}',
      };

      final lineItems = cartState.items.map((item) {
        return {
          'product_id': int.tryParse(item.product.id) ?? 0,
          'quantity': item.quantity,
        };
      }).toList();

      final order = await wooCommerceService.createOrder(
        customerData: customerData,
        lineItems: lineItems,
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();

        // Clear cart
        ref.read(cartProvider.notifier).clearCart();

        // Show success dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Responsive.cardRadius),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: LaapakColors.success, size: 64),
                SizedBox(height: Responsive.md),
                Text(
                  'تم إنشاء الطلب بنجاح!',
                  style: LaapakTypography.titleMedium(
                    color: LaapakColors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Responsive.sm),
                Text(
                  'رقم الطلب: ${order['id']}',
                  style: LaapakTypography.bodyMedium(
                    color: LaapakColors.primary,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: Responsive.sm),
                Text(
                  'سيتم التواصل معك قريباً لتأكيد تفاصيل الشحن والدفع.',
                  style: LaapakTypography.bodySmall(
                    color: LaapakColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'حسناً',
                  style: LaapakTypography.button(color: LaapakColors.primary),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء إنشاء الطلب: ${e.toString()}'),
            backgroundColor: LaapakColors.error,
          ),
        );
      }
    }
  }
}

class _CartBottomSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);

    return Container(
      decoration: BoxDecoration(
        color: LaapakColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Responsive.lg),
          topRight: Radius.circular(Responsive.lg),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: Responsive.md),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: LaapakColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: Responsive.screenPadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'السلة',
                      style: LaapakTypography.headlineSmall(
                        color: LaapakColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: LaapakColors.textSecondary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: cartState.items.isEmpty
                    ? EmptyState(
                        icon: Icons.shopping_cart_outlined,
                        title: 'السلة فارغة',
                        subtitle: 'لم يتم إضافة أي منتجات إلى السلة',
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: Responsive.screenPadding,
                        itemCount: cartState.items.length,
                        itemBuilder: (context, index) {
                          final item = cartState.items[index];
                          return _CartItemCard(item: item);
                        },
                      ),
              ),
              if (cartState.isNotEmpty)
                _buildTotalSection(context, ref, cartState),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTotalSection(
    BuildContext context,
    WidgetRef ref,
    CartState cartState,
  ) {
    return Container(
      padding: Responsive.screenPadding,
      decoration: BoxDecoration(
        color: LaapakColors.surface,
        border: Border(top: BorderSide(color: LaapakColors.borderLight)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي:',
                style: LaapakTypography.titleMedium(
                  color: LaapakColors.textPrimary,
                ),
              ),
              Text(
                '${cartState.totalPrice.toStringAsFixed(0)} ج.م',
                style: LaapakTypography.titleLarge(color: LaapakColors.primary),
              ),
            ],
          ),
          SizedBox(height: Responsive.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _CartOverlayMethods.confirmOrder(context, ref);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: LaapakColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: Responsive.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'تأكيد الطلب',
                style: LaapakTypography.bodyMedium(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends ConsumerWidget {
  final CartItem item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.only(bottom: Responsive.md),
      child: Padding(
        padding: Responsive.cardPaddingInsets,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Responsive.buttonRadius),
              child: CachedImage(
                imageUrl: item.product.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: Responsive.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: LaapakTypography.titleSmall(
                      color: LaapakColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: Responsive.xs),
                  if (item.product.price != null)
                    Text(
                      '${item.product.price!.toStringAsFixed(0)} ج.م',
                      style: LaapakTypography.bodyMedium(
                        color: LaapakColors.primary,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: LaapakColors.textSecondary,
                  ),
                  onPressed: () {
                    if (item.quantity > 1) {
                      ref
                          .read(cartProvider.notifier)
                          .updateQuantity(item.product.id, item.quantity - 1);
                    } else {
                      ref
                          .read(cartProvider.notifier)
                          .removeFromCart(item.product.id);
                    }
                  },
                ),
                Text(
                  '${item.quantity}',
                  style: LaapakTypography.titleMedium(
                    color: LaapakColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: LaapakColors.primary,
                  ),
                  onPressed: () {
                    ref
                        .read(cartProvider.notifier)
                        .updateQuantity(item.product.id, item.quantity + 1);
                  },
                ),
              ],
            ),
            SizedBox(width: Responsive.sm),
            IconButton(
              icon: Icon(Icons.delete_outline, color: LaapakColors.error),
              onPressed: () {
                ref.read(cartProvider.notifier).removeFromCart(item.product.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper class to access confirmOrder from bottom sheet
class _CartOverlayMethods {
  static void confirmOrder(BuildContext context, WidgetRef ref) {
    const CartOverlay(child: SizedBox())._confirmOrder(context, ref);
  }
}
