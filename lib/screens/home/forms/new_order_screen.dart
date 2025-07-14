import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/controllers/local_find_service.dart';
import 'package:pos_desktop_loop/db/tables/product/products_table.dart';
import 'package:pos_desktop_loop/providers/cart_provider.dart';
import 'package:pos_desktop_loop/screens/home/checkout_screen.dart';
import 'package:provider/provider.dart';

class NewOrderScreen extends StatefulWidget {
  final int shopId;
  const NewOrderScreen({super.key, required this.shopId});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  List<ProductsTable> products = [];
  var localFindService = LocalFindService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final cartProvider = Provider.of<CartProvider>(context);
    final shopCart = cartProvider.getCartForShop(widget.shopId) ?? {};

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actionsPadding: EdgeInsets.symmetric(horizontal: width * 0.02),
        toolbarHeight: height * 0.08,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Sales Point',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryGreen,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Badge(
            label: Text(
              shopCart.length.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CheckoutScreen(shopId: widget.shopId),
                    ),
                  ),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Search bar (optional - you can add this later)
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: TextField(
                  //     decoration: InputDecoration(
                  //       hintText: 'Search products...',
                  //       prefixIcon: Icon(Icons.search),
                  //       border: OutlineInputBorder(),
                  //     ),
                  //   ),
                  // ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.02,
                        vertical: 8,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: ProductItemCard(
                            width: width,
                            height: height,
                            product: products[index],
                            shopId: widget.shopId,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }

  Future<void> fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final result = await localFindService.getAllProductsForCartForAdmin();
      setState(() => products = result);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $error')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

class ProductItemCard extends StatelessWidget {
  const ProductItemCard({
    super.key,
    required this.width,
    required this.height,
    required this.product,
    required this.shopId,
  });

  final double width;
  final double height;
  final ProductsTable product;
  final int shopId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height * 0.15,
      child: Card(
        color: AppColors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            context.read<CartProvider>().addItem(shopId, product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${product.name} added to cart')),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(width * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: height * 0.005),

                // Category (if available)
                Text(
                  'Category: ${product.categoryId}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const Spacer(),

                // Price and Add to Cart button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ksh. ${product.unitPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
