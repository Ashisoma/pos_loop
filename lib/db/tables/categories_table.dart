import 'package:pos_desktop_loop/db/helpers/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class CategoriesTable {
  static const String tableName = 'categories';

  final int? id;
  final String name;
  final String description;
  final DateTime? createdAt;

  CategoriesTable({
    this.id,
    required this.name,
    required this.description,
    this.createdAt,
  });

  factory CategoriesTable.fromSqfliteDataBase(Map<String, dynamic> map) {
    return CategoriesTable(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      createdAt:
          map['created_at'] != null
              ? DateTime.parse(map['created_at'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  static Future<void> createCategoriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(150) NOT NULL,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        description TEXT NOT NULL
      )
    ''');
  }

  static Future<void> dropCategoriesTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }

  // check if a category already exists by name
  static Future<bool> categoryExists(String name) async {
    Database db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'name = ?',
      whereArgs: [name],
    );
    return maps.isNotEmpty;
  }

  static Future<List<CategoriesTable>> getAllCategories() async {
    Database db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return CategoriesTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<int> insertCategory(CategoriesTable category) async {
    Database db = await DatabaseHelper().database;

    return await db.insert(
      tableName,
      category.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateCategory(CategoriesTable category) async {
    Database db = await DatabaseHelper().database;

    return await db.update(
      tableName,
      category.toJson(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  static Future<int> deleteCategory(int id) async {
    Database db = await DatabaseHelper().database;

    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  // get a category by name
  static Future<CategoriesTable?> getCategoryByName(String name) async {
    Database db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'name = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return CategoriesTable.fromSqfliteDataBase(maps.first);
    }
    return null;
  }
}
