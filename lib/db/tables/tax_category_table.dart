import 'package:pos_desktop_loop/db/helpers/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class TaxCategoryTable {
  static const String tableCategories = 'tax_category';

  // taxcategory, taxt%age, description
  final int? id;
  final String name;
  final double taxPercentage;
  final String? description;
  final int? sync;

  TaxCategoryTable({
    this.id,
    required this.name,
    required this.taxPercentage,
    this.description,
    this.sync,
  });

  factory TaxCategoryTable.fromSqfliteDataBase(Map<String, dynamic> map) {
    return TaxCategoryTable(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      taxPercentage: map['tax_percentage']?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      sync: map['sync']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tax_percentage': taxPercentage,
      'description': description,
      'sync': sync,
    }..removeWhere((key, value) => value == null);
  }

  static Future<void> createTaxCategoryTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableCategories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(150) NOT NULL,
        tax_percentage REAL NOT NULL,
        description TEXT,
        sync INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  static Future<void> dropTaxCategoryTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableCategories');
  }

  static Future<List<TaxCategoryTable>> getAllTaxCategories() async {
    Database db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(tableCategories);
    return List.generate(maps.length, (i) {
      return TaxCategoryTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<int> insertTaxCategory(TaxCategoryTable taxCategory) async {
    Database db = await DatabaseHelper().database;
    return await db.insert(
      tableCategories,
      taxCategory.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateTaxCategory(TaxCategoryTable taxCategory) async {
    Database db = await DatabaseHelper().database;

    return await db.update(
      tableCategories,
      taxCategory.toJson(),
      where: 'id = ?',
      whereArgs: [taxCategory.id],
    );
  }


    static Future<TaxCategoryTable?> getCategoryByName(String name) async {
    Database db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableCategories,
      where: 'name = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return TaxCategoryTable.fromSqfliteDataBase(maps.first);
    }
    return null;
  }

  static Future<int> deleteTaxCategory(int id) async {
    Database db = await DatabaseHelper().database;
    return await db.delete(tableCategories, where: 'id = ?', whereArgs: [id]);
  }
}
