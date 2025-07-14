// ignore_for_file: slash_for_doc_comments

import 'package:sqflite/sqflite.dart';

/**
 * 
 * CREATE TABLE shop_stock_summary (
  report_date        DATE        NOT NULL,
  shop_id            BIGINT      NOT NULL REFERENCES shop(shop_id),
  total_stock_value  DECIMAL(14,2) NOT NULL,
  pct_stock_over_90d DECIMAL(5,2) NOT NULL,    -- % of stock qty aged > 90 days
  PRIMARY KEY(report_date, shop_id)
);

 */

class ShopStockSummaryTable {
  static const String tableShopStockSummary = 'shop_stock_summary';
  final int id;
  final String reportDate;
  final int shopId;
  final double totalStockValue;
  final double pctStockOver90d;

  ShopStockSummaryTable({
    required this.id,
    required this.reportDate,
    required this.shopId,
    required this.totalStockValue,
    required this.pctStockOver90d,
  });

  factory ShopStockSummaryTable.fromSqfliteDataBase(Map<String, dynamic> map) {
    return ShopStockSummaryTable(
      id: map['id']?.toInt() ?? 0,
      reportDate: map['report_date']?.toString() ?? '',
      shopId: map['shop_id']?.toInt() ?? 0,
      totalStockValue: map['total_stock_value']?.toDouble() ?? 0.0,
      pctStockOver90d: map['pct_stock_over_90d']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_date': reportDate,
      'shop_id': shopId,
      'total_stock_value': totalStockValue,
      'pct_stock_over_90d': pctStockOver90d,
    };
  }

  static Future<void> createShopStockSummaryTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableShopStockSummary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        report_date DATE NOT NULL,
        shop_id BIGINT NOT NULL REFERENCES shop(shop_id),
        total_stock_value DECIMAL(14,2) NOT NULL,
        pct_stock_over_90d DECIMAL(5,2) NOT NULL
      )
    ''');
  }

  static Future<void> dropShopStockSummaryTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableShopStockSummary');
  }

  static Future<void> deleteShopStockSummaryTable(Database db) async {
    await db.execute('DELETE FROM $tableShopStockSummary');
  }

  static Future<List<ShopStockSummaryTable>> getAllShopStockSummary(
      Database db) async {
    final List<Map<String, dynamic>> maps =
        await db.query(tableShopStockSummary);
    return List.generate(maps.length, (i) {
      return ShopStockSummaryTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<List<ShopStockSummaryTable>> getShopStockSummaryByDate(
      Database db, String date) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableShopStockSummary,
      where: 'report_date = ?',
      whereArgs: [date],
    );
    return List.generate(maps.length, (i) {
      return ShopStockSummaryTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<List<ShopStockSummaryTable>> getShopStockSummaryByShopId(
      Database db, int shopId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableShopStockSummary,
      where: 'shop_id = ?',
      whereArgs: [shopId],
    );
    return List.generate(maps.length, (i) {
      return ShopStockSummaryTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<List<ShopStockSummaryTable>> getShopStockSummaryByDateAndShopId(
      Database db, String date, int shopId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableShopStockSummary,
      where: 'report_date = ? AND shop_id = ?',
      whereArgs: [date, shopId],
    );
    return List.generate(maps.length, (i) {
      return ShopStockSummaryTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<void> insertShopStockSummary(
      Database db, ShopStockSummaryTable shopStockSummary) async {
    await db.insert(
      tableShopStockSummary,
      shopStockSummary.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateShopStockSummary(
      Database db, ShopStockSummaryTable shopStockSummary) async {
    await db.update(
      tableShopStockSummary,
      shopStockSummary.toJson(),
      where: 'id = ?',
      whereArgs: [shopStockSummary.id],
    );
  }

  static Future<void> deleteShopStockSummary(
      Database db, int id) async {
    await db.delete(
      tableShopStockSummary,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteShopStockSummaryByDate(
      Database db, String date) async {
    await db.delete(
      tableShopStockSummary,
      where: 'report_date = ?',
      whereArgs: [date],
    );
  }

  static Future<void> deleteShopStockSummaryByShopId(
      Database db, int shopId) async {
    await db.delete(
      tableShopStockSummary,
      where: 'shop_id = ?',
      whereArgs: [shopId],
    );
  }

  
}
