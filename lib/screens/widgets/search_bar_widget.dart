import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/providers/inventory_provider.dart';
import 'package:pos_desktop_loop/providers/product_provider.dart';
import 'package:pos_desktop_loop/screens/home/forms/new_category_screen.dart';
import 'package:pos_desktop_loop/screens/home/forms/new_product_screen.dart';
import 'package:pos_desktop_loop/screens/home/forms/new_tax_category_form_screen.dart';
import 'package:pos_desktop_loop/screens/home/imports/import_cateogry_screen.dart';
import 'package:pos_desktop_loop/screens/home/imports/import_product_screen.dart';
import 'package:pos_desktop_loop/screens/home/imports/import_tax_category_screen.dart';
import 'package:pos_desktop_loop/screens/home/select_shop_screen.dart';
import 'package:provider/provider.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final TabController? tabController;
  final List<Widget>? tabs;
  final int? shopId;
  final String searchQuery;

  const SearchAppBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.tabController,
    this.tabs,
    this.shopId,
    required this.searchQuery,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 1.5);

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    _isSearching = widget.searchQuery.isNotEmpty;
  }

  @override
  void didUpdateWidget(covariant SearchAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      title:
          _isSearching
              ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: InputBorder.none,
                ),
                onChanged: widget.onChanged,
              )
              : Text(
                'Product Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryGreen,
                ),
              ),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                widget.onChanged('');
              }
            });
          },
        ),
        if (!_isSearching) ...[
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              final productProvider = Provider.of<ProductsProvider>(
                context,
                listen: false,
              );
              final categoryProvider = Provider.of<InventoryByShopProvider>(
                context,
                listen: false,
              );

              switch (value) {
                case 'import':
                  final currentIndex = widget.tabController!.index;

                  Widget importPage;
                  switch (currentIndex) {
                    case 0:
                      importPage = ImportProductsPage();
                      break;
                    case 1:
                      importPage = ImportCategoriesPage();
                      break;
                    case 2:
                      importPage = ImportTaxCategoriesPage();
                      break;
                    default:
                      // Fallback just in case index is out of bounds
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Invalid tab selection.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                  }

                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => importPage));
                  break;

                case 'add':
                  switch (widget.tabController!.index) {
                    case 0: // Products & Services

                      if (widget.shopId == null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    SelectShopScreen(route: 'products'),
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => NewProductScreen(
                                  shopId: widget.shopId!,
                                  isEdit: false,
                                  isService: false,
                                ),
                          ),
                        ).then((_) => productProvider.fetchProducts());
                      }

                      break;
                    case 1: // Categories
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  const NewCategoryScreen(isEdit: false),
                        ),
                      ).then((_) => categoryProvider.fetchCategories());
                      break;
                    case 2: // Tax Categories
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  const NewTaxCategoryFormScreen(isEdit: false),
                        ),
                      ).then((_) => productProvider.fetchTaxCategories());
                      break;
                  }
                  break;
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'import',
                    child: Text(
                      'Import ${['Products & Services', 'Categories', 'Tax Categories'][widget.tabController!.index]}',
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'add',
                    child: Text(
                      'Add new ${['item', 'category', 'tax category'][widget.tabController!.index]}',
                    ),
                  ),
                ],
          ),
        ],
      ],
      bottom:
          widget.tabController != null && widget.tabs != null
              ? TabBar(
                controller: widget.tabController,
                labelColor: AppColors.primaryGreen,
                unselectedLabelColor: Colors.black,
                indicatorColor: AppColors.primaryGreen,
                tabs: widget.tabs!,
              )
              : null,
    );
  }
}
