import 'package:pos_desktop_loop/db/helpers/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class ExpenseType {
  static const String _tableName = 'expense_types';

  int? id;
  int businessId;
  int shopId;
  String name;
  DateTime createdAt;

  ExpenseType({
    this.id,
    required this.businessId,
    required this.shopId,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': businessId,
      'shop_id': shopId,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ExpenseType.fromMap(Map<String, dynamic> map) {
    return ExpenseType(
      id: map['id'],
      businessId: map['business_id'],
      shopId: map['shop_id'],
      name: map['name'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  static Future<void> createTable(Database db) async {
    
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER NOT NULL,
        shop_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  static Future<int> insertExpenseType(ExpenseType type) async {
    final db = await DatabaseHelper().database;
    return await db.insert(_tableName, type.toMap());
  }

  static Future<List<ExpenseType>> getExpenseTypes(
     {
      
    required String businessId,
    required String shopId,
  }) async {
    final db = await DatabaseHelper().database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'business_id = ? AND shop_id = ?',
      whereArgs: [businessId, shopId],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) => ExpenseType.fromMap(maps[i]));
  }

  static Future<int> deleteExpenseType( int id) async {
    final db = await DatabaseHelper().database;

    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}
