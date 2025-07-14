import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/db/controllers/local_find_service.dart';
import 'package:pos_desktop_loop/db/tables/shop/shop_table.dart';
import 'package:pos_desktop_loop/screens/home/forms/new_order_screen.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/screens/widgets/custom_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectShopScreen extends StatefulWidget {
  const SelectShopScreen({super.key});

  @override
  State<SelectShopScreen> createState() => _SelectShopScreenState();
}

class _SelectShopScreenState extends State<SelectShopScreen> {
  final LocalFindService _findService = LocalFindService();
  List<ShopTable> _shops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchShops();
  }

  void fetchShops() async {
    final shops = await _findService.getAllShops();
    setState(() {
      _shops = shops;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actionsPadding: EdgeInsets.symmetric(horizontal: width * 0.01),
        toolbarHeight: height * 0.1,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Select a Shop",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: AppColors.primaryGreen,
          ),
        ),
      ),
      drawer: CustomDrawerWidget(),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: EdgeInsets.all(width * 0.04),
                itemCount: _shops.length,
                itemBuilder: (context, index) {
                  final shop = _shops[index];
                  return GestureDetector(
                    onTap: () {
                      // save shop id to shared preferences or state management
                      // and navigate to the new order screen
                      _saveSelectedShop(shop.shopId!);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NewOrderScreen(shopId: shop.shopId!),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                      child: Container(
                        padding: EdgeInsets.all(width * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shop.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              shop.branch,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }

  void _saveSelectedShop(int i) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('_shopIdKey', i);
  }
}
