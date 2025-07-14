import 'package:pos_desktop_loop/db/helpers/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class CustomerTable {
  static const String tableName = 'customer';
  final int? customerId;
  String? name;
  String? address;
  String? phone;
  String? description;
  String? companyName;
  int? businessId;
  // role can be customer or Service Provider

  CustomerTable({
    this.customerId,
     this.name,
     this.address,
     this.businessId,
     this.phone,
     this.description,
     this.companyName,
  });

  factory CustomerTable.fromSqfliteDataBase(Map<String, dynamic> map) {
    return CustomerTable(
      customerId: map['customer_id'] ?? 0,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      description: map['description'] ?? '',
      companyName: map['company_name'] ?? '',
      businessId: map['business_id']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'name': name,
      'address': address,
      'phone': phone,
      'description': description,
      'company_name': companyName,
      'business_id': businessId,
    };
  }

  static Future<void> createCustomerTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        customer_id INTEGER PRIMARY KEY,
        name VARCHAR(150) NOT NULL,
        address VARCHAR(150) NULL,
        phone VARCHAR(150) NULL,
        role VARCHAR(50) NULL,
        company_name VARCHAR(150) NULL,
        business_id INTEGER NULL,
        description VARCHAR(150) NULL
      )
    ''');
  }

  static Future<void> dropCustomerTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }

  static Future<List<CustomerTable>> getAllcustomers() async {
    Database db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return CustomerTable.fromSqfliteDataBase(maps[i]);
    });
  }



  static Future<int> insertcustomer(CustomerTable customer) async {
    Database db = await DatabaseHelper().database;

    return await db.insert(
      tableName,
      customer.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // if the customer already exists
  static Future<bool> customerExists(String phone) async {
    Database db = await DatabaseHelper().database;

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'phone = ?',
      whereArgs: [phone],
    );

    return maps.isNotEmpty;
  }

  static Future<int> updatecustomer(CustomerTable customer) async {
    Database db = await DatabaseHelper().database;

    return await db.update(
      tableName,
      customer.toJson(),
      where: 'customer_id = ?',
      whereArgs: [customer.customerId],
    );
  }

  static Future<int> deletecustomer(int customerId) async {
    Database db = await DatabaseHelper().database;

    return await db.delete(
      tableName,
      where: 'customer_id = ?',
      whereArgs: [customerId],
    );
  }

  static Future<CustomerTable?> getcustomerById(String customerId) async {
    Database db = await DatabaseHelper().database;

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'customer_id = ?',
      whereArgs: [customerId],
    );

    if (maps.isNotEmpty) {
      return CustomerTable.fromSqfliteDataBase(maps.first);
    }
    return null;
  }
}
