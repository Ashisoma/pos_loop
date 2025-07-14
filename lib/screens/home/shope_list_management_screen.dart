import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/controllers/local_insert_service.dart';
import 'package:pos_desktop_loop/db/tables/shop/shop_table.dart';
import 'package:pos_desktop_loop/screens/home/forms/new_shop_screen.dart';

class ShopeListManagementScreen extends StatefulWidget {
  const ShopeListManagementScreen({super.key});

  @override
  State<ShopeListManagementScreen> createState() =>
      _ShopeListManagementScreenState();
}

class _ShopeListManagementScreenState extends State<ShopeListManagementScreen> {
  List<ShopTable> shops = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> _toggleShopActivation(int shopId, bool isActive) async {
    try {
      // First get the current shop data
      final shop = await ShopTable.getShopById(shopId);
      if (shop != null) {
        // Update just the isActive status
        await ShopTable.updateShop(
          ShopTable(
            shopId: shop.shopId,
            name: shop.name,
            branch: shop.branch,
            phone: shop.phone,
            isActive: isActive,
            managerId: shop.managerId,
            website: shop.website,
            email: shop.email,
            vatNumber: shop.vatNumber,
            pinNumber: shop.pinNumber,
            createdBy: shop.createdBy,
            businessId: shop.businessId,
            createdAt: shop.createdAt,
            slogan: shop.slogan,
          ),
        );
        fetchData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shop ${isActive ? 'activated' : 'deactivated'}'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update shop status: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Shop Management',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: AppColors.primaryGreen,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value == 'add') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewShopScreen(isEdit: false),
                  ),
                );
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'add',
                    child: Text('Add new shop'),
                  ),
                ],
          ),
        ],
      ),
      body:
          shops.isEmpty
              ? const Center(
                child: Text(
                  'No shops found. Add a shop to get started.',
                  style: TextStyle(fontSize: 16),
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: shops.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final shop = shops[index];
                  return ListTile(
                    title: Text(shop.name),
                    subtitle: Text(
                      shop.branch.isNotEmpty
                          ? shop.branch
                          : 'No branch specified',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        NewShopScreen(isEdit: true, data: shop),
                              ),
                            );
                          },
                        ),
                        Switch(
                          value: shop.isActive == 1,
                          onChanged:
                              (value) =>
                                  _toggleShopActivation(shop.shopId!, value),
                          activeColor: AppColors.primaryGreen,
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  void fetchData() async {
    final shopsData = await ShopTable.getAllShops();
    setState(() {
      shops = shopsData;
    });
  }
}
