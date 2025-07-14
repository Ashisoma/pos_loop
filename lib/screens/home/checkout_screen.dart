import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/tables/product/products_table.dart';
import 'package:pos_desktop_loop/db/tables/shop/shop_table.dart';
import 'package:pos_desktop_loop/providers/cart_provider.dart';
import 'package:pos_desktop_loop/screens/home/store/checkout_complete_screen.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  final int shopId;
  const CheckoutScreen({super.key, required this.shopId});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String shopName = '';

  @override
  void initState() {
    super.initState();
    setupShopName();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final shopCart = cartProvider.getCartForShop(widget.shopId) ?? {};
    final subtotal = cartProvider.getSubtotalForShop(widget.shopId);
    const vatRate = 0.16;
    final vat = subtotal * vatRate;
    final total = subtotal + vat;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Checkout - $shopName'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                shopCart.isEmpty
                    ? const Center(child: Text('Cart is empty'))
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: shopCart.length,
                      itemBuilder: (context, index) {
                        final productId = shopCart.keys.elementAt(index);
                        final item = shopCart[productId]!;
                        return _buildCartItem(
                          product: item.product,
                          quantity: item.quantity,
                          onRemove:
                              () => cartProvider.removeFromCart(
                                widget.shopId,
                                item.product.id!,
                              ),
                          onQuantityChanged: (newQty) {
                            if (newQty > 0) {
                              cartProvider.updateQuantity(
                                widget.shopId,
                                item.product,
                                newQty,
                              );
                            }
                          },
                        );
                      },
                    ),
          ),
          // Bottom Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, -2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildTotalRow("Subtotal", subtotal),
                _buildTotalRow("VAT (16%)", vat),
                const Divider(),
                _buildTotalRow("Total", total, isTotal: true),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed:
                        shopCart.isEmpty
                            ? null
                            : () => _processCheckout(context, widget.shopId),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text(
                      'Complete Order',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem({
    required ProductsTable product,
    required int quantity,
    required VoidCallback onRemove,
    required Function(int) onQuantityChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Info Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image/Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.shopping_bag,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ksh. ${product.unitPrice.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Total Price
                Text(
                  'Ksh. ${(quantity * product.unitPrice).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Quantity Controls
            Row(
              children: [
                // Quantity Adjuster
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: () => onQuantityChanged(quantity - 1),
                      ),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: () => onQuantityChanged(quantity + 1),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Remove Button
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onRemove,
                  color: Colors.redAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _processCheckout(BuildContext context, int shopId) {
    // final cartProvider = Provider.of<CartProvider>(context, listen: false);
    // cartProvider.clearCartForShop(shopId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompleteCheckoutScreen(shopId: shopId),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order completed successfully')),
    );
  }

  void setupShopName() async {
    final shop = await ShopTable.getShopById(widget.shopId);
    if (mounted) {
      setState(() {
        shopName = shop?.name ?? '';
      });
    }
  }
}

Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          "Ksh. ${amount.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.primaryGreen : Colors.black,
          ),
        ),
      ],
    ),
  );
}
