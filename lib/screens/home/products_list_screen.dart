import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/providers/inventory_provider.dart';
import 'package:pos_desktop_loop/screens/widgets/category_widget.dart';
import 'package:pos_desktop_loop/screens/widgets/products_widget.dart';
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

  @override
  void initState() {
    super.initState();
    _setShopId();
    _tabController = TabController(length: 4, vsync: this);
    // Fetch initial data
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
      productProvider.fetchServiceProducts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actionsPadding: EdgeInsets.symmetric(horizontal: width * 0.01),
        toolbarHeight: height * 0.1,
        backgroundColor: Colors.white,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: Colors.black,
          indicatorColor: AppColors.primaryGreen,
          tabs: const [
            Tab(text: 'Products'),
            Tab(text: 'Services'),
            Tab(text: 'Categories'),
            Tab(text: 'Tax Categories'),
          ],
        ),
        title: Text(
          'Product Management',
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
            // use the three dotted icon for the menu
            icon: Icon(Icons.more_vert, color: Colors.black),
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
                  // Handle import based on current tab
                  final tabNames = [
                    'Products',
                    'Services',
                    'Categories',
                    'Tax Categories',
                  ];
                  // Implement your import functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Import ${tabNames[_tabController.index]} functionality not implemented yet.',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  break;
                case 'add':
                  switch (_tabController.index) {
                    case 0: // Products
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => NewProductScreen(
                                shopId: shopId!,
                                isEdit: false,
                                isService: false,
                              ),
                        ),
                      ).then((_) => productProvider.fetchProducts());
                      break;
                    case 1: // Services
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => NewProductScreen(
                                isEdit: false,
                                isService: true,
                                shopId: shopId!,
                              ),
                        ),
                      ).then((_) => productProvider.fetchServiceProducts());
                      break;
                    case 2: // Categories
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  const NewCategoryScreen(isEdit: false),
                        ),
                      ).then((_) => categoryProvider.fetchCategories());
                      break;
                    case 3: // Tax Categories
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
                      'Import ${['Products', 'Services', 'Categories', 'Tax Categories'][_tabController.index]}',
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'add',
                    child: Text(
                      'Add new ${['product', 'service', 'category', 'tax category'][_tabController.index]}',
                    ),
                  ),
                ],
          ),
        ],
      ),
      drawer: const CustomDrawerWidget(),
      body: TabBarView(
        controller: _tabController,
        children: [
          Consumer<ProductsProvider>(
            builder: (context, provider, _) {
              final categoryProvider = Provider.of<InventoryByShopProvider>(
                context,
              );
              return ProductsTabWidget(
                height: height,
                width: width,
                products: provider.products,
                isService: false,
                categories: categoryProvider.categories,
              );
            },
          ),
          Consumer<ProductsProvider>(
            builder: (context, provider, _) {
              final categoryProvider = Provider.of<InventoryByShopProvider>(
                context,
              );
              return ProductsTabWidget(
                height: height,
                width: width,
                products: provider.serviceProducts,
                isService: true,
                categories: categoryProvider.categories,
              );
            },
          ),
          Consumer<InventoryByShopProvider>(
            builder:
                (context, provider, _) => CategoriesTabWidget(
                  height: height,
                  width: width,
                  categories: provider.categories,
                ),
          ),
          Consumer<ProductsProvider>(
            builder:
                (context, provider, _) => TaxCategoriesTabWidget(
                  height: height,
                  width: width,
                  categories: provider.taxCategories,
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

class ProductsTabWidget extends StatefulWidget {
  final bool isService;
  final double height;
  final double width;
  final List<ProductsTable> products;
  final List<CategoriesTable> categories;

  const ProductsTabWidget({
    super.key,
    required this.height,
    required this.width,
    required this.products,
    this.isService = false,
    required this.categories,
  });

  @override
  State<ProductsTabWidget> createState() => _ProductsTabWidgetState();
}

class _ProductsTabWidgetState extends State<ProductsTabWidget> {
  String _searchQuery = '';
  int? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    // get categories from the provider
    final categoryProvider = Provider.of<InventoryByShopProvider>(context);
    List<ProductsTable> filtered =
        widget.products.where((product) {
          final matchesSearch = product.name.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
          final matchesCategory =
              _selectedCategoryId == null ||
              product.categoryId == _selectedCategoryId;
          return matchesSearch && matchesCategory;
        }).toList();

    return Container(
      height: widget.height,
      color: AppColors.naturalBackground,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: [
                ReusableSearchBar(
                  hintText:
                      'Search ${widget.isService ? "services" : "products"}...',
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _selectedCategoryId,
                  hint: const Text("Filter by Category"),
                  isExpanded: true,
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text("All Categories"),
                    ),
                    ...categoryProvider.categories.map(
                      (cat) => DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          /// ⬇️ Only this section scrolls
          SizedBox(
            height: widget.height * 0.6,
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
                                'No products/services found',
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
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoriesTabWidget extends StatefulWidget {
  final double height;
  final double width;
  final List<CategoriesTable> categories;

  const CategoriesTabWidget({
    super.key,
    required this.height,
    required this.width,
    required this.categories,
  });

  @override
  State<CategoriesTabWidget> createState() => _CategoriesTabWidgetState();
}

class _CategoriesTabWidgetState extends State<CategoriesTabWidget> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered =
        widget.categories
            .where(
              (cat) =>
                  cat.name.toLowerCase().contains(_searchQuery.toLowerCase()),
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
              ReusableSearchBar(
                onChanged: (val) => setState(() => _searchQuery = val),
                hintText: 'Search categories...',
              ),
              const SizedBox(height: 16),

              if (filtered.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'No products/services found',
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

  const TaxCategoriesTabWidget({
    super.key,
    required this.height,
    required this.width,
    required this.categories,
  });

  @override
  State<TaxCategoriesTabWidget> createState() => _TaxCategoriesTabWidgetState();
}

class _TaxCategoriesTabWidgetState extends State<TaxCategoriesTabWidget> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered =
        widget.categories
            .where(
              (cat) =>
                  cat.name.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

    return SingleChildScrollView(
      child: Container(
        height: widget.height,
        color: AppColors.naturalBackground,
        child: Column(
          children: [
            const SizedBox(height: 8),
            ReusableSearchBar(
              onChanged: (val) => setState(() => _searchQuery = val),
              hintText: 'Search tax categories...',
            ),
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
