// demo_data.dart
import 'package:pos_desktop_loop/db/controllers/local_find_service.dart';
import 'package:pos_desktop_loop/db/controllers/local_insert_service.dart';
import 'package:pos_desktop_loop/db/tables/business_table.dart';
import 'package:pos_desktop_loop/db/tables/categories_table.dart';
import 'package:pos_desktop_loop/db/tables/costomer_table.dart';
import 'package:pos_desktop_loop/db/tables/product/products_table.dart';
import 'package:pos_desktop_loop/db/tables/shop/shop_table.dart';
import 'package:pos_desktop_loop/db/tables/stock/inventory_table.dart';
import 'package:pos_desktop_loop/db/tables/supplier_table.dart';
import 'package:pos_desktop_loop/db/tables/tax_category_table.dart';
import 'package:pos_desktop_loop/db/tables/user_table.dart';

class DemoData {
  final LocalInsertService _insertService = LocalInsertService();

  Future<void> insertAllDemoData() async {
    await _insertDemoUsers();
    await _insertDemoSuppliersAndCustomers();
    await _insertDemoTaxCategories();
    await _insertDemoCategories();
    await _insertDemoShops();
    await _insertDemoProducts();
    await _insertDemoInventory();
  }

  Future<void> _insertDemoUsers() async {
    final users = [
      UserTable(
        fullName: 'Admin User',
        password: 'admin123', // Note: In real app, store hashed passwords
        role: 'Admin',
        email: 'admin@mail.com',
        phoneNumber: '07128732983',
        pinCode: '2323',
        isActive: true,
        sync: 0,
      ),
      UserTable(
        fullName: 'Manager User',
        password: 'manager123',
        role: 'Manager',
        email: 'manager@mail.com',
        phoneNumber: '07008932983',
        isActive: false,
        sync: 0,
      ),
      UserTable(
        fullName: 'Cashier User',
        password: 'cashier123',
        role: 'Cashier',
        email: 'cash@mail.com',
        phoneNumber: '0722009983',
        isActive: true,
        sync: 0,
      ),
    ];

    for (final user in users) {
      await UserTable.insertUserProfile(user);
    }
  }

  // insert demo business
  Future<void> _insertDemoBusiness() async {
    final users = await LocalFindService().getAllUsers();

    // This method can be used to insert demo business data if needed
    final business = Business(
      businessName: 'Demo Business',
      createdBy: users.firstWhere((u) => u.role == 'Admin').fullName,
      createdAt: DateTime.now(),
    );

    await Business.insertBusiness(business);
  }

  Future<void> _insertDemoSuppliersAndCustomers() async {
    final suppliers = [
      SupplierTable(
        phone: '+1234567890',
        address: '123 Supplier St, Industrial Area',
        companyName: "Global Foods",
        contactPerson: 'John Doe',
      ),
      SupplierTable(
        phone: '+1987654321',
        address: '456 Electronics Blvd, Tech Park',
        companyName: "Tech Gadgets",
        contactPerson: 'Jane Smith',
      ),
    ];

    final customers = [
      CustomerTable(
        name: 'Premium Restaurant',
        phone: '+1122334455',
        address: '789 Main St, Downtown',
        companyName: "Premium Restaurant",
      ),
      CustomerTable(
        name: 'Cafe Delight',
        phone: '+5566778899',
        address: '321 Coffee Ave, Riverside',
        companyName: "Cafe Delight",
      ),
    ];

    for (final supplier in suppliers) {
      await _insertService.insertSupplier(supplier);
    }

    for (final customer in customers) {
      await _insertService.insertCustomer(customer);
    }
  }

  Future<void> _insertDemoTaxCategories() async {
    final taxCategories = [
      TaxCategoryTable(
        name: 'No Tax',
        taxPercentage: 0.0,
        description: 'Tax exempt items',
      ),
      TaxCategoryTable(
        name: 'Standard VAT',
        taxPercentage: 15.0,
        description: 'Standard value added tax',
      ),
      TaxCategoryTable(
        name: 'Reduced VAT',
        taxPercentage: 8.0,
        description: 'Reduced rate for basic goods',
      ),
    ];

    for (final taxCategory in taxCategories) {
      await _insertService.insertTaxCategory(taxCategory);
    }
  }

  Future<void> _insertDemoCategories() async {
    final categories = [
      CategoriesTable(name: 'Beverages', description: 'All drink items'),
      CategoriesTable(name: 'Food', description: 'All food items'),
      CategoriesTable(
        name: 'Electronics',
        description: 'Electronic devices and accessories',
      ),
      CategoriesTable(
        name: 'Office Supplies',
        description: 'Items for office use',
      ),
    ];

    for (final category in categories) {
      await _insertService.insertCategory(category);
    }
  }

  Future<void> _insertDemoShops() async {
    final shops = [
      ShopTable(
        name: 'Main Store',
        branch: '123 Retail Park, City Center',
        phone: '+1112223333',
        isActive: true,
      ),
      ShopTable(
        name: 'Downtown Branch',
        branch: '456 Business District',
        phone: '+4445556666',
        isActive: true,
      ),
    ];

    for (final shop in shops) {
      await _insertService.insertShop(shop);
    }
  }

  Future<void> _insertDemoProducts() async {
    // First get the categories and tax categories we just inserted
    final categories = await LocalFindService().getAllCategories();
    final taxCategories = await LocalFindService().getAllTaxCategories();
    final shops = await LocalFindService().getAllShops();

    final products = [
      ProductsTable(
        name: 'Mineral Water 500ml',
        categoryId: categories.firstWhere((c) => c.name == 'Beverages').id!,
        taxCategory:
            taxCategories.firstWhere((t) => t.name == 'Standard VAT').id!,
        unitPrice: 50,
        retailPrice: 80,
        quantity: 100,
        buyingPrice: 40,
        restockLevel: 20,
        isOffer: false,
        isService: false,
        wholesalePrice: 20,
        shopId: shops.firstWhere((s) => s.name == 'Main Store').shopId!,
      ),
      ProductsTable(
        name: 'Energy Drink',
        categoryId: categories.firstWhere((c) => c.name == 'Beverages').id!,
        taxCategory:
            taxCategories.firstWhere((t) => t.name == 'Standard VAT').id!,
        unitPrice: 100,
        retailPrice: 250,
        quantity: 50,
        buyingPrice: 80,
        restockLevel: 10,
        isOffer: false,
        isService: false,
        wholesalePrice: 150,

        shopId: shops.firstWhere((s) => s.name == 'Main Store').shopId!,
      ),
      ProductsTable(
        name: 'Wireless Mouse',
        categoryId: categories.firstWhere((c) => c.name == 'Electronics').id!,
        taxCategory:
            taxCategories.firstWhere((t) => t.name == 'Standard VAT').id!,
        unitPrice: 100,
        retailPrice: 159,
        quantity: 30,
        buyingPrice: 80,
        restockLevel: 5,
        isOffer: false,
        isService: false,
        wholesalePrice: 70,
        shopId: shops.firstWhere((s) => s.name == 'Downtown Branch').shopId!,
      ),
      ProductsTable(
        name: 'Notebook',
        categoryId:
            categories.firstWhere((c) => c.name == 'Office Supplies').id!,
        taxCategory: taxCategories.firstWhere((t) => t.name == 'No Tax').id!,
        unitPrice: 150,
        retailPrice: 300,
        quantity: 80,
        buyingPrice: 100,
        restockLevel: 15,
        isOffer: false,
        isService: false,
        wholesalePrice: 120,
        shopId: shops.firstWhere((s) => s.name == 'Main Store').shopId!,
      ),
    ];

    for (final product in products) {
      await _insertService.insertProduct(product);
    }
  }

  Future<void> _insertDemoInventory() async {
    final products = await LocalFindService().getAllProducts();
    final shops = await LocalFindService().getAllShops();

    final inventoryItems = [
      InventoryTable(
        productId:
            products.firstWhere((p) => p.name == 'Mineral Water 500ml').id!,
        shopId: shops.firstWhere((s) => s.name == 'Main Store').shopId!,
        description: '',
        sync: 0,
        quantity: 60,
        lastRestocked: DateTime.now().subtract(const Duration(days: 2)),
      ),
      InventoryTable(
        productId:
            products.firstWhere((p) => p.name == 'Mineral Water 500ml').id!,
        shopId: shops.firstWhere((s) => s.name == 'Downtown Branch').shopId!,
        quantity: 40,
        description: '',
        lastRestocked: DateTime.now().subtract(const Duration(days: 5)),
      ),
      InventoryTable(
        productId: products.firstWhere((p) => p.name == 'Energy Drink').id!,
        shopId: shops.firstWhere((s) => s.name == 'Main Store').shopId!,
        quantity: 30,
        lastRestocked: DateTime.now().subtract(const Duration(days: 1)),
      ),
      InventoryTable(
        productId: products.firstWhere((p) => p.name == 'Wireless Mouse').id!,
        shopId: shops.firstWhere((s) => s.name == 'Downtown Branch').shopId!,
        quantity: 15,
        lastRestocked: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];

    for (final item in inventoryItems) {
      await _insertService.insertInventory(item);
    }
  }
}
