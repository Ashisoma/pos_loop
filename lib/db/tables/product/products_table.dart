import 'package:pos_desktop_loop/db/helpers/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class ProductsTable {
  static const String tableProducts = 'products';

  final int? id;
  final int categoryId;
  final String name;
  String? barcode;
  final int? quantity;
  final double? retailPrice;
  final int? taxCategory;
  final double? wholesalePrice;
  final double unitPrice;
  final double? offerPrice;
  final int shopId;
  bool isService;
  bool isOffer;
  int? restockLevel;
  double? buyingPrice;

  ProductsTable({
    this.id,
    required this.categoryId,
    required this.name,
    this.quantity,
    this.retailPrice,
    this.taxCategory,
    this.wholesalePrice,
    required this.shopId,
    required this.unitPrice,
    this.offerPrice,
    this.barcode,
    this.isOffer = false,
    this.isService = false,
    this.restockLevel,
    this.buyingPrice,
  });

  factory ProductsTable.fromSqfliteDataBase(Map<String, dynamic> map) {
    return ProductsTable(
      id: map['id']?.toInt() ?? 0,
      categoryId: map['category_id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
      retailPrice: map['retail_price']?.toDouble() ?? 0.0,
      taxCategory: map['tax_category']?.toInt() ?? 0,
      wholesalePrice: map['wholesale_price']?.toDouble() ?? 0.0,
      shopId: map['shop_id']?.toInt() ?? 0,
      unitPrice: map['unit_price']?.toDouble() ?? 0.0,
      buyingPrice: map['buying_price']?.toDouble() ?? 0.0,
      offerPrice: map['offer_price']?.toDouble(),
      barcode: map['barcode'] ?? '',
      restockLevel: map['restock_level']?.toInt(),
      isOffer: map['is_offer'] == 1,
      isService: map['is_service'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'quantity': quantity,
      'retail_price': retailPrice,
      'tax_category': taxCategory,
      'restock_level': restockLevel,
      'wholesale_price': wholesalePrice,
      'unit_price': unitPrice,
      'offer_price': offerPrice,
      'is_service': isService ? 1 : 0,
      'buying_price': buyingPrice,
      'barcode': barcode,
      'shop_id': shopId,
      'is_offer': isOffer ? 1 : 0,
    };
  }

  static Future<void> createProductsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableProducts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        name VARCHAR(150) NOT NULL,
        quantity INTEGER NOT NULL,
        retail_price REAL NULL,
        tax_category INTEGER NULL,
        wholesale_price REAL NULL,
        unit_price REAL NULL,
        restock_level INTEGER NULL,
        is_service INTEGER DEFAULT 0,
        is_offer INTEGER DEFAULT 0,
        buying_price REAL NULL,
        shop_id INTEGER NOT NULL,
        barcode TEXT NULL,
        offer_price REAL
      )
    ''');
  }

  static Future<int> insertProduct(ProductsTable product) async {
    Database db = await DatabaseHelper().database;
    await db.insert(tableProducts, product.toJson());
    return await db
        .query(tableProducts, columns: ['id'], orderBy: 'id DESC', limit: 1)
        .then((value) => value[0]['id'] as int);
  }

  static Future<ProductsTable?> getProductById(int productId) async {
    Database db = await DatabaseHelper().database;
    List<Map<String, dynamic>> result = await db.query(
      tableProducts,
      where: 'id = ?',
      whereArgs: [productId],
    );
    if (result.isNotEmpty) {
      return ProductsTable.fromSqfliteDataBase(result.first);
    }
    return null;
  }

  static Future<List<ProductsTable>> getServiceProducts() async {
    Database db = await DatabaseHelper().database;
    List<Map<String, dynamic>> result = await db.query(
      tableProducts,
      where: 'is_service = ?',
      whereArgs: [1],
    );
    return result.map((e) => ProductsTable.fromSqfliteDataBase(e)).toList();
  }

  static Future<bool> productValidExists(String name, int categoryId,int shopId) async {
    Database db = await DatabaseHelper().database;
    List<Map<String, dynamic>> result = await db.query(
      tableProducts,
      where: 'name = ?, category_id = ?, shop_id = ?',
      whereArgs: [name, categoryId, shopId],
    );
    return result.isNotEmpty;
  }


   static Future<bool> productExists(String name) async {
    Database db = await DatabaseHelper().database;
    List<Map<String, dynamic>> result = await db.query(
      tableProducts,
      where: 'name = ?',
      whereArgs: [name],
    );
    return result.isNotEmpty;
  }

  static Future<void> dropProductsTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableProducts');
  }

  static Future<int> updateProductsTable(ProductsTable product) async {
    Database db = await DatabaseHelper().database;
    return await db.update(
      tableProducts,
      product.toJson(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  static Future<List<ProductsTable>> getAllProductsByShopId(int shopId) async {
    Database db = await DatabaseHelper().database;
    List<Map<String, dynamic>> products = await db.query(
      tableProducts,
      where: 'shop_id = ?',
      whereArgs: [shopId],
    );
    return products.map((e) => ProductsTable.fromSqfliteDataBase(e)).toList();
  }

  static Future<List<ProductsTable>> getAllProducts() async {
    Database db = await DatabaseHelper().database;
    List<Map<String, dynamic>> products = await db.query(tableProducts);
    return products.map((e) => ProductsTable.fromSqfliteDataBase(e)).toList();
  }

  static Future<List<ProductsTable>> getAllProductsByCategoryId(
    int categoryId,
  ) async {
    Database db = await DatabaseHelper().database;
    List<Map<String, dynamic>> products = await db.query(
      tableProducts,
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return products.map((e) => ProductsTable.fromSqfliteDataBase(e)).toList();
  }

  static Future<int> deleteProduct(int productId) async {
    Database db = await DatabaseHelper().database;
    return await db.delete(
      tableProducts,
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  static Future<ProductsTable> getProductByName(String name) async {
    Database db = await DatabaseHelper().database;
    List<Map<String, dynamic>> result = await db.query(
      tableProducts,
      where: 'name = ?',
      whereArgs: [name],
    );
    return ProductsTable.fromSqfliteDataBase(result.first);
  }
}
