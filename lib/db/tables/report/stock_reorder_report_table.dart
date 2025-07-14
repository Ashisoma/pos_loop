/**
 * 
 * 
 * CREATE TABLE stock_reorder_report (
  report_date        DATE        NOT NULL,
  shop_id            BIGINT      NOT NULL REFERENCES shop(shop_id),
  product_id         BIGINT      NOT NULL REFERENCES product(product_id),
  quantity_on_hand   INT         NOT NULL,
  reorder_level      INT         NOT NULL,     -- e.g. minimal safety stock
  reorder_qty        INT         NOT NULL,     -- e.g. EOQ or fixed batch
  needs_reorder      BOOLEAN     GENERATED ALWAYS AS 
                      (quantity_on_hand <= reorder_level) STORED,
  PRIMARY KEY(report_date, shop_id, product_id),
  sync             INT         NOT NULL DEFAULT 0
);

 */
library;

import 'package:sqflite/sqflite.dart';

class StockReorderReportTable {
  static const String tableStockReorderReport = 'stock_reorder_report';

  final String reportDate;
  final int shopId;
  final int productId;
  final int quantityOnHand;
  final int reorderLevel;
  final int reorderQty;
  final bool needsReorder;
  final int sync;

  StockReorderReportTable({
    required this.reportDate,
    required this.shopId,
    required this.productId,
    required this.quantityOnHand,
    required this.reorderLevel,
    required this.reorderQty,
    required this.needsReorder,
    required this.sync,
  });

  factory StockReorderReportTable.fromSqfliteDataBase(
    Map<String, dynamic> map,
  ) {
    return StockReorderReportTable(
      reportDate: map['report_date']?.toString() ?? '',
      shopId: map['shop_id']?.toInt() ?? 0,
      productId: map['product_id']?.toInt() ?? 0,
      quantityOnHand: map['quantity_on_hand']?.toInt() ?? 0,
      reorderLevel: map['reorder_level']?.toInt() ?? 0,
      reorderQty: map['reorder_qty']?.toInt() ?? 0,
      needsReorder: map['needs_reorder'] == 1,
      sync: map['sync']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_date': reportDate,
      'shop_id': shopId,
      'product_id': productId,
      'quantity_on_hand': quantityOnHand,
      'reorder_level': reorderLevel,
      'reorder_qty': reorderQty,
      'needs_reorder': needsReorder ? 1 : 0,
      'sync': sync,
    };
  }

  static Future<void> createStockReorderReportTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableStockReorderReport (
        report_date        DATE        NOT NULL,
        shop_id            BIGINT      NOT NULL REFERENCES shop(shop_id),
        product_id         BIGINT      NOT NULL REFERENCES product(product_id),
        quantity_on_hand   INT         NOT NULL,
        reorder_level      INT         NOT NULL,
        reorder_qty        INT         NOT NULL,
        needs_reorder      BOOLEAN     GENERATED ALWAYS AS 
                            (quantity_on_hand <= reorder_level) STORED,
        PRIMARY KEY(report_date, shop_id, product_id),
        sync             INT         NOT NULL DEFAULT 0
      )
    ''');
  }

  static Future<void> dropStockReorderReportTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableStockReorderReport');
  }

  static Future<List<StockReorderReportTable>> getAllStockReorderReports(
    Database db,
  ) async {
    final List<Map<String, dynamic>> maps =
        await db.query(tableStockReorderReport);
    return List.generate(maps.length, (i) {
      return StockReorderReportTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<List<StockReorderReportTable>> getStockReorderReportsByDate(
    Database db,
    String date,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableStockReorderReport,
      where: 'report_date = ?',
      whereArgs: [date],
    );
    return List.generate(maps.length, (i) {
      return StockReorderReportTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<List<StockReorderReportTable>> getStockReorderReportsByShopId(
    Database db,
    int shopId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableStockReorderReport,
      where: 'shop_id = ?',
      whereArgs: [shopId],
    );
    return List.generate(maps.length, (i) {
      return StockReorderReportTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<List<StockReorderReportTable>> getStockReorderReportsByProductId(
    Database db,
    int productId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableStockReorderReport,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    return List.generate(maps.length, (i) {
      return StockReorderReportTable.fromSqfliteDataBase(maps[i]);
    });
  } 
}
