import 'package:pos_desktop_loop/db/helpers/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class Business {
  int? id;
  String businessName;
  String createdBy;
  DateTime createdAt;

  Business({
    this.id,
    required this.businessName,
    required this.createdBy,
    required this.createdAt,
  });

  factory Business.fromSqfliteDataBase(Map<String, dynamic> map) {
    return Business(
      id: map['id'] ?? 0,
      businessName: map['business_name'] ?? '',
      createdBy: map['created_by'] ?? '',
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // create table
  static const String tableBusiness = 'business';

  // create table query
  static const String createTableQuery = '''CREATE TABLE $tableBusiness (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    business_name TEXT NOT NULL,
    created_by TEXT NOT NULL,
    created_at TEXT NOT NULL
  )''';
  static Future<void> createBusinessTable(Database db) async {
    await db.execute(createTableQuery);
  }

  static Future<void> dropBusinessTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableBusiness');
  }

  // insert business
  static Future<int> insertBusiness( Business business) async {
    final db = await DatabaseHelper().database;

    return await db.insert(
      tableBusiness,
      business.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // get all businesses
  static Future<List<Business>> getAllBusinesses() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(tableBusiness);
    return List.generate(maps.length, (i) {
      return Business.fromSqfliteDataBase(maps[i]);
    });
  }

  // get business by id
  static Future<Business?> getBusinessById( int id) async {
    final db = await DatabaseHelper().database;

    final List<Map<String, dynamic>> maps = await db.query(
      tableBusiness,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Business.fromSqfliteDataBase(maps.first);
    }
    return null;
  }

  // update business
  static Future<int> updateBusiness(Business business) async {
    final db = await DatabaseHelper().database;

    return await db.update(
      tableBusiness,
      business.toJson(),
      where: 'id = ?',
      whereArgs: [business.id],
    );
  }
}
