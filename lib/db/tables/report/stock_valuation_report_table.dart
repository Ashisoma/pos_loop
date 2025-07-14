/**
 * 
 * CREATE TABLE stock_valuation_report (
  report_date        DATE        NOT NULL,                       -- the snapshot date
  shop_id            BIGINT      NOT NULL REFERENCES shop(shop_id),
  product_id         BIGINT      NOT NULL REFERENCES product(product_id),
  quantity_on_hand   INT         NOT NULL,                       -- from inventory
  avg_unit_cost      DECIMAL(12,2) NOT NULL,                     -- weighted avg cost
  total_value        DECIMAL(14,2) GENERATED ALWAYS AS         -- qty × cost
                      (quantity_on_hand * avg_unit_cost) STORED,
  PRIMARY KEY(report_date, shop_id, product_id)
);
 * 
 */
library;

import 'package:sqflite/sqflite.dart';

class StockValuationReportTable {
  static const String tableStockValuationReport = 'stock_valuation_report';

  final String reportDate;
  final int shopId;
  final int productId;
  final int quantityOnHand;
  final double avgUnitCost;
  final double totalValue;

  StockValuationReportTable({
    required this.reportDate,
    required this.shopId,
    required this.productId,
    required this.quantityOnHand,
    required this.avgUnitCost,
    required this.totalValue,
  });

  factory StockValuationReportTable.fromSqfliteDataBase(
    Map<String, dynamic> map,
  ) {
    return StockValuationReportTable(
      reportDate: map['report_date']?.toString() ?? '',
      shopId: map['shop_id']?.toInt() ?? 0,
      productId: map['product_id']?.toInt() ?? 0,
      quantityOnHand: map['quantity_on_hand']?.toInt() ?? 0,
      avgUnitCost: map['avg_unit_cost']?.toDouble() ?? 0.0,
      totalValue: map['total_value']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_date': reportDate,
      'shop_id': shopId,
      'product_id': productId,
      'quantity_on_hand': quantityOnHand,
      'avg_unit_cost': avgUnitCost,
      'total_value': totalValue,
    };
  }

  static Future<void> createStockValuationReportTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableStockValuationReport (
        report_date TEXT NOT NULL,
        shop_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity_on_hand INTEGER NOT NULL,
        avg_unit_cost REAL NOT NULL,
        total_value REAL,
        PRIMARY KEY(report_date, shop_id, product_id)
      )
    ''');
  }

  static Future<void> dropStockValuationReportTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableStockValuationReport');
  }

  static Future<List<StockValuationReportTable>> getAllStockValuationReports(
    Database db,
  ) async {
    final List<Map<String, dynamic>> maps =
        await db.query(tableStockValuationReport);
    return List.generate(
      maps.length,
      (i) => StockValuationReportTable.fromSqfliteDataBase(maps[i]),
    );
  }

  static Future<List<StockValuationReportTable>> getStockValuationReportByDate(
    Database db,
    String reportDate,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableStockValuationReport,
      where: 'report_date = ?',
      whereArgs: [reportDate],
    );
    return List.generate(
      maps.length,
      (i) => StockValuationReportTable.fromSqfliteDataBase(maps[i]),
    );
  }

  static Future<List<StockValuationReportTable>> getStockValuationReportByShopId(
    Database db,
    int shopId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableStockValuationReport,
      where: 'shop_id = ?',
      whereArgs: [shopId],
    );
    return List.generate(
      maps.length,
      (i) => StockValuationReportTable.fromSqfliteDataBase(maps[i]),
    );
  }

  static Future<List<StockValuationReportTable>> getStockValuationReportByProductId(
    Database db,
    int productId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableStockValuationReport,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    return List.generate(
      maps.length,
      (i) => StockValuationReportTable.fromSqfliteDataBase(maps[i]),
    );
  }

  static Future<void> insertStockValuationReport(
    Database db,
    StockValuationReportTable stockValuationReport,
  ) async {
    await db.insert(
      tableStockValuationReport,
      stockValuationReport.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateStockValuationReport(
    Database db,
    StockValuationReportTable stockValuationReport,
  ) async {
    await db.update(
      tableStockValuationReport,
      stockValuationReport.toJson(),
      where: 'report_date = ? AND shop_id = ? AND product_id = ?',
      whereArgs: [
        stockValuationReport.reportDate,
        stockValuationReport.shopId,
        stockValuationReport.productId,
      ],
    );
  }

  static Future<void> deleteStockValuationReport(
    Database db,
    String reportDate,
    int shopId,
    int productId,
  ) async {
    await db.delete(
      tableStockValuationReport,
      where: 'report_date = ? AND shop_id = ? AND product_id = ?',
      whereArgs: [reportDate, shopId, productId],
    );
  }

  static Future<void> deleteStockValuationReportByDate(
    Database db,
    String reportDate,
  ) async {
    await db.delete(
      tableStockValuationReport,
      where: 'report_date = ?',
      whereArgs: [reportDate],
    );
  }

  static Future<void> deleteStockValuationReportByShopId(
    Database db,
    int shopId,
  ) async {
    await db.delete(
      tableStockValuationReport,
      where: 'shop_id = ?',
      whereArgs: [shopId],
    );
  }

  static Future<void> deleteStockValuationReportByProductId(
    Database db,
    int productId,
  ) async {
    await db.delete(
      tableStockValuationReport,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  static Future<void> deleteAllStockValuationReports(Database db) async {
    await db.delete(tableStockValuationReport);
  }

  static Future<bool> checkIfStockValuationReportExists(
    Database db,
    String reportDate,
    int shopId,
    int productId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableStockValuationReport,
      where: 'report_date = ? AND shop_id = ? AND product_id = ?',
      whereArgs: [reportDate, shopId, productId],
    );
    return maps.isNotEmpty;
  }

  static Future<void> deleteStockValuationReportByShopIdAndProductId(
    Database db,
    int shopId,
    int productId,
  ) async {
    await db.delete(
      tableStockValuationReport,
      where: 'shop_id = ? AND product_id = ?',
      whereArgs: [shopId, productId],
    );
  }

  static Future<void> deleteStockValuationReportByDateAndShopId(
    Database db,
    String reportDate,
    int shopId,
  ) async {
    await db.delete(
      tableStockValuationReport,
      where: 'report_date = ? AND shop_id = ?',
      whereArgs: [reportDate, shopId],
    );
  }

  static Future<void> deleteStockValuationReportByDateAndProductId(
    Database db,
    String reportDate,
    int productId,
  ) async {
    await db.delete(
      tableStockValuationReport,
      where: 'report_date = ? AND product_id = ?',
      whereArgs: [reportDate, productId],
    );
  }

  static Future<void> deleteStockValuationReportByShopIdAndProductIdAndDate(
    Database db,
    int shopId,
    int productId,
    String reportDate,
  ) async {
    await db.delete(
      tableStockValuationReport,
      where: 'shop_id = ? AND product_id = ? AND report_date = ?',
      whereArgs: [shopId, productId, reportDate],
    );
  }

  static Future<void> deleteStockValuationReportByShopIdAndDate(
    Database db,
    int shopId,
    String reportDate,
  ) async {
    await db.delete(
      tableStockValuationReport,
      where: 'shop_id = ? AND report_date = ?',
      whereArgs: [shopId, reportDate],
    );
  }
}
