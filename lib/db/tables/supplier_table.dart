import 'package:pos_desktop_loop/db/helpers/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class SupplierTable {
  static const String tableName = 'supplier';
  final int? supplierId;
  String? address;
  String? phone;
  String? companyName;
  String? contactPerson;
  int? businessId;
  String? description;

  SupplierTable({
    this.supplierId,
    this.address,
    this.phone,
    this.companyName,
    this.contactPerson,
    this.description,
    this.businessId,
  });

  factory SupplierTable.fromSqfliteDataBase(Map<String, dynamic> map) {
    return SupplierTable(
      supplierId: map['supplier_id'] ?? 0,
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      companyName: map['company_name'] ?? '',
      contactPerson: map['contact_person'] ?? '',
      description: map['description'] ?? '',
      businessId: map['business_id']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier_id': supplierId,
      'address': address,
      'phone': phone,
      'company_name': companyName,
      'contact_person': contactPerson,
      'description': description,
      'business_id': businessId,
    };
  }

  static Future<void> createSupplierTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        supplier_id INTEGER PRIMARY KEY,
        address TEXT,
        phone TEXT,
        company_name TEXT,
        business_id INTEGER,
        contact_person TEXT,
        description TEXT
      )
    ''');
  }

  static Future<void> dropSupplierTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }

  static Future<List<SupplierTable>> getAllSuppliers() async {
    Database db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return SupplierTable.fromSqfliteDataBase(maps[i]);
    });
  }

  // get where role == Supplier
  static Future<List<SupplierTable>> getAllSuppliersByRole(String role) async {
    Database db = await DatabaseHelper().database;

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'role = ?',
      whereArgs: [role],
    );

    return List.generate(maps.length, (i) {
      return SupplierTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<int> insertSupplier(SupplierTable supplier) async {
    Database db = await DatabaseHelper().database;

    return await db.insert(
      tableName,
      supplier.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // if the supplier already exists
  static Future<bool> supplierExists(String phone) async {
    Database db = await DatabaseHelper().database;

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'phone = ?',
      whereArgs: [phone],
    );

    return maps.isNotEmpty;
  }

  static Future<int> updateSupplier(SupplierTable supplier) async {
    Database db = await DatabaseHelper().database;

    return await db.update(
      tableName,
      supplier.toJson(),
      where: 'supplier_id = ?',
      whereArgs: [supplier.supplierId],
    );
  }

  static Future<int> deleteSupplier(int supplierId) async {
    Database db = await DatabaseHelper().database;

    return await db.delete(
      tableName,
      where: 'supplier_id = ?',
      whereArgs: [supplierId],
    );
  }

  static Future<SupplierTable?> getSupplierById(String supplierId) async {
    Database db = await DatabaseHelper().database;

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'supplier_id = ?',
      whereArgs: [supplierId],
    );

    if (maps.isNotEmpty) {
      return SupplierTable.fromSqfliteDataBase(maps.first);
    }
    return null;
  }
}
