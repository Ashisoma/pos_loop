import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/providers/inventory_provider.dart';
import 'package:pos_desktop_loop/screens/widgets/category_widget.dart';
import 'package:pos_desktop_loop/screens/widgets/products_widget.dart';
import 'package:pos_desktop_loop/screens/widgets/search_bar_widget.dart';
import 'package:pos_desktop_loop/screens/widgets/search_widget.dart';
import 'package:pos_desktop_loop/screens/widgets/tax_category.dart';
import 'package:provider/provider.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/tables/categories_table.dart';
import 'package:pos_desktop_loop/db/tables/product/products_table.dart';
import 'package:pos_desktop_loop/db/tables/tax_category_table.dart';
import 'package:pos_desktop_loop/providers/product_provider.dart';
import 'package:pos_desktop_loop/screens/home/forms/new_category_screen.dart';
import 'package:pos_desktop_loop/screens/home/forms/new_tax_category_form_screen.dart';
import 'package:pos_desktop_loop/screens/home/forms/new_product_screen.dart';
import 'package:pos_desktop_loop/screens/widgets/custom_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? shopId;
  String _searchQuery = '';
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _setShopId();
    _tabController = TabController(length: 3, vsync: this); // Changed to 3 tabs
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
        _searchQuery = ''; // Clear search when changing tabs
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductsProvider>(
        context,
        listen: false,
      );
      final categoryProvider = Provider.of<InventoryByShopProvider>(
        context,
        listen: false,
      );
      productProvider.fetchProducts();
      categoryProvider.fetchCategories();
      productProvider.fetchTaxCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SearchAppBar(
        shopId: shopId,
        hintText:
            'Search ${['items', 'categories', 'tax categories'][_tabController.index]}...',
        onChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
        },
        searchQuery: _searchQuery,
        tabController: _tabController,
        tabs: const [
          Tab(text: 'Products & Services'),
          Tab(text: 'Categories'),
          Tab(text: 'Tax Categories'),
        ],
      ),
      drawer: const CustomDrawerWidget(),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Merged Products & Services tab
          Consumer<ProductsProvider>(
            builder: (context, provider, _) {
              final categoryProvider = Provider.of<InventoryByShopProvider>(
                context,
              );
              return ProductsAndServicesTabWidget(
                height: height,
                width: width,
                products: provider.products,
                searchQuery: _searchQuery,
                categories: categoryProvider.categories,
              );
            },
          ),
          // Rest remains the same
          Consumer<InventoryByShopProvider>(
            builder:
                (context, provider, _) => CategoriesTabWidget(
                  height: height,
                  width: width,
                  categories: provider.categories,
                  searchQuery: _searchQuery,
                ),
          ),
          Consumer<ProductsProvider>(
            builder:
                (context, provider, _) => TaxCategoriesTabWidget(
                  height: height,
                  width: width,
                  categories: provider.taxCategories,
                  searchQuery: _searchQuery,
                ),
          ),
        ],
      ),
    );
  }

  void _setShopId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      shopId = prefs.getInt('_shopIdKey');
    });
  }
}

class ProductsAndServicesTabWidget extends StatefulWidget {
  final double height;
  final double width;
  final List<ProductsTable> products;
  final List<CategoriesTable> categories;
  final String searchQuery;

  const ProductsAndServicesTabWidget({
    super.key,
    required this.height,
    required this.width,
    required this.products,
    required this.categories,
    required this.searchQuery,
  });

  @override
  State<ProductsAndServicesTabWidget> createState() =>
      _ProductsAndServicesTabWidgetState();
}

class _ProductsAndServicesTabWidgetState
    extends State<ProductsAndServicesTabWidget> {
  int? _selectedCategoryId;
  bool _showProducts = true;
  bool _showServices = true;

  @override
  Widget build(BuildContext context) {
    List<ProductsTable> filtered =
        widget.products.where((product) {
          final matchesSearch = product.name.toLowerCase().contains(
            widget.searchQuery.toLowerCase(),
          );
          final matchesCategory =
              _selectedCategoryId == null ||
              product.categoryId == _selectedCategoryId;
          final matchesType =
              (_showProducts && !product.isService) ||
              (_showServices && product.isService);
          return matchesSearch && matchesCategory && matchesType;
        }).toList();

    return Container(
      height: widget.height,
      color: AppColors.naturalBackground,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    hint: const Text("Filter by Category"),
                    isExpanded: true,
                    onChanged:
                        (val) => setState(() => _selectedCategoryId = val),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text("All Categories"),
                      ),
                      ...widget.categories.map(
                        (cat) => DropdownMenuItem(
                          value: cat.id,
                          child: Text(cat.name),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    FilterChip(
                      label: const Text('Products'),
                      selected: _showProducts,
                      onSelected: (bool selected) {
                        setState(() {
                          _showProducts = selected;
                          if (!_showProducts && !_showServices) {
                            _showServices = true;
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Services'),
                      selected: _showServices,
                      onSelected: (bool selected) {
                        setState(() {
                          _showServices = selected;
                          if (!_showProducts && !_showServices) {
                            _showProducts = true;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: widget.width * 0.02,
                right: widget.width * 0.02,
                bottom: widget.height * 0.1,
              ),
              child: Column(
                children:
                    filtered.isEmpty
                        ? [
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text(
                                'No items found',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ]
                        : List.generate(
                          filtered.length,
                          (index) => ProductItemCard(
                            width: widget.width,
                            height: widget.height,
                            index: index,
                            product: filtered[index],
                            // onEdit: () => _handleEditProduct(filtered[index]),
                            // onDelete:
                            // () => _handleDeleteProduct(filtered[index]),
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleEditProduct(ProductsTable product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => NewProductScreen(
              shopId: product.shopId!,
              isEdit: true,
              isService: product.isService,
              product: product,
            ),
      ),
    ).then((_) {
      // Refresh data after editing
      Provider.of<ProductsProvider>(context, listen: false).fetchProducts();
    });
  }

  Future<void> _handleDeleteProduct(ProductsTable product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text('Are you sure you want to delete ${product.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final success = await ProductsTable.deleteProduct(product.id!);
      if ((success == 1) && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} deleted successfully')),
        );
        Provider.of<ProductsProvider>(context, listen: false).fetchProducts();
      }
    }
  }
}

class CategoriesTabWidget extends StatefulWidget {
  final double height;
  final double width;
  final List<CategoriesTable> categories;
  final String searchQuery;

  const CategoriesTabWidget({
    super.key,
    required this.height,
    required this.width,
    required this.categories,
    required this.searchQuery,
  });

  @override
  State<CategoriesTabWidget> createState() => _CategoriesTabWidgetState();
}

class _CategoriesTabWidgetState extends State<CategoriesTabWidget> {
  @override
  Widget build(BuildContext context) {
    final filtered =
        widget.categories
            .where(
              (cat) => cat.name.toLowerCase().contains(
                widget.searchQuery.toLowerCase(),
              ),
            )
            .toList();

    return Scaffold(
      backgroundColor: AppColors.naturalBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: widget.width * 0.02,
            right: widget.width * 0.02,
            bottom: widget.height * 0.1,
            top: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              if (filtered.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'No categories found',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                )
              else
                Column(
                  children: List.generate(
                    filtered.length,
                    (index) => CategoryItemCard(
                      width: widget.width,
                      height: widget.height,
                      index: index,
                      category: filtered[index],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaxCategoriesTabWidget extends StatefulWidget {
  final double height;
  final double width;
  final List<TaxCategoryTable> categories;
  final String searchQuery;

  const TaxCategoriesTabWidget({
    super.key,
    required this.height,
    required this.width,
    required this.categories,
    required this.searchQuery,
  });

  @override
  State<TaxCategoriesTabWidget> createState() => _TaxCategoriesTabWidgetState();
}

class _TaxCategoriesTabWidgetState extends State<TaxCategoriesTabWidget> {
  @override
  Widget build(BuildContext context) {
    final filtered =
        widget.categories
            .where(
              (cat) => cat.name.toLowerCase().contains(
                widget.searchQuery.toLowerCase(),
              ),
            )
            .toList();

    return SingleChildScrollView(
      child: Container(
        height: widget.height,
        color: AppColors.naturalBackground,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                height: widget.height,
                padding: EdgeInsets.symmetric(horizontal: widget.width * 0.02),
                child:
                    filtered.isEmpty
                        ? const Center(
                          child: Text(
                            'No tax categories found',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                        : ListView.builder(
                          itemCount: filtered.length,
                          shrinkWrap: true,
                          physics:
                              const AlwaysScrollableScrollPhysics(), // Ensure it always scrolls
                          itemBuilder: (context, index) {
                            return TaxCategoryItemCard(
                              width: widget.width,
                              height: widget.height,
                              index: index,
                              category: filtered[index],
                            );
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
