import 'package:pos_desktop_loop/db/helpers/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class ShopTable {
  static const String tableShop = 'shop';

  final int? shopId;
  final String name;
  final String branch;
  final String phone;
  final int? managerId;
  final bool isActive; // Changed from int to bool
  String? website;
  String? email;
  String? vatNumber;
  String? pinNumber;
  int? createdBy;
  int? businessId;
  DateTime? createdAt;
  String? slogan;

  ShopTable({
    this.shopId,
    required this.name,
    required this.phone,
    required this.branch,
    required this.isActive, // Made required since it's not nullable
    this.managerId,
    this.website,
    this.email,
    this.vatNumber,
    this.pinNumber,
    this.createdBy,
    this.businessId,
    this.createdAt,
    this.slogan,
  });

  factory ShopTable.fromSqfliteDataBase(Map<String, dynamic> map) {
    return ShopTable(
      shopId: map['shop_id'] ?? 0,
      name: map['name'] ?? '',
      branch: map['branch'] ?? '',
      phone: map['phone'] ?? '',
      isActive: map['isActive'] == 1, // Convert int to bool
      managerId: map['manager_id'] ?? 0,
      website: map['website'] ?? '',
      email: map['email'] ?? '',
      vatNumber: map['vat_number'] ?? '',
      pinNumber: map['pin_number'] ?? '',
      createdBy: map['created_by'] ?? 0,
      slogan: map['slogan'] ?? '',
      businessId: map['business_id']?.toInt() ?? 0,
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shop_id': shopId,
      'name': name,
      'branch': branch,
      'phone': phone,
      'isActive': isActive ? 1 : 0, // Convert bool to int
      'manager_id': managerId,
      'website': website,
      'email': email,
      'vat_number': vatNumber,
      'slogan': slogan,
      'pin_number': pinNumber,
      'created_by': createdBy,
      'business_id': businessId,
      'created_at':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  static Future<void> createShopTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableShop (
        shop_id INTEGER PRIMARY KEY,
        name VARCHAR(150) NOT NULL,
        branch VARCHAR(150) NOT NULL,
        phone VARCHAR(15) NOT NULL,
        isActive INTEGER DEFAULT FALSE,
        created_at TEXT NOT NULL,
        created_by INTEGER NULL,
        website VARCHAR(150) NULL,
        email VARCHAR(150) NULL,
        slogan VARCHAR(150) NULL,
        vat_number VARCHAR(150) NULL,
        pin_number VARCHAR(150) NULL,
        business_id INTEGER NULL,

        manager_id INTEGER NULL
      )
    ''');
  }

  static Future<void> dropShopTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableShop');
  }

  static Future<List<ShopTable>> getAllShops() async {
    Database db = await DatabaseHelper().database;

    final List<Map<String, dynamic>> maps = await db.query(tableShop);
    return List.generate(maps.length, (i) {
      return ShopTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<int> insertShop(ShopTable shop) async {
    Database db = await DatabaseHelper().database;
    return await db.insert(
      tableShop,
      shop.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // check if a shop already exists by phone
  static Future<bool> shopExists(String phone) async {
    Database db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableShop,
      where: 'phone = ?',
      whereArgs: [phone],
    );
    return maps.isNotEmpty;
  }

  // get shop by manager id
  static Future<ShopTable?> getShopByManagerId(int managerId) async {
    Database db = await DatabaseHelper().database;

    final List<Map<String, dynamic>> maps = await db.query(
      tableShop,
      where: 'manager_id = ?',
      whereArgs: [managerId],
    );
    if (maps.isNotEmpty) {
      return ShopTable.fromSqfliteDataBase(maps.first);
    }
    return null;
  }

  // set manager id for a shop
  static Future<int> setManagerId(int shopId, int managerId) async {
    Database db = await DatabaseHelper().database;

    return await db.update(
      tableShop,
      {'manager_id': managerId},
      where: 'shop_id = ?',
      whereArgs: [shopId],
    );
  }

  static Future<int> updateShop(ShopTable shop) async {
    Database db = await DatabaseHelper().database;

    return await db.update(
      tableShop,
      shop.toJson(),
      where: 'shop_id = ?',
      whereArgs: [shop.shopId],
    );
  }

  static Future<int> deleteShop(int shopId) async {
    Database db = await DatabaseHelper().database;
    return await db.delete(
      tableShop,
      where: 'shop_id = ?',
      whereArgs: [shopId],
    );
  }

  static Future<ShopTable?> getShopById(int shopId) async {
    Database db = await DatabaseHelper().database;

    final List<Map<String, dynamic>> maps = await db.query(
      tableShop,
      where: 'shop_id = ?',
      whereArgs: [shopId],
    );
    if (maps.isNotEmpty) {
      return ShopTable.fromSqfliteDataBase(maps.first);
    }
    return null;
  }

  static Future<ShopTable> getShopByName(String name) async {
    Database db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableShop,
      where: 'name = ?',
      whereArgs: [name],
    );
    print(maps);
    return ShopTable.fromSqfliteDataBase(maps.first);
  }
}
