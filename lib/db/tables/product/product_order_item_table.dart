import 'package:sqflite/sqflite.dart';

class PurchaseOrderItem {
  static const String tablePurchaseOrderItem = 'purchase_order_item';

  final int purchaseOrderItemId;
  final int purchaseOrderId;
  final int productId;
  final int quantityOrder;
  final double unitPrice;


  PurchaseOrderItem({
    required this.purchaseOrderItemId,
    required this.purchaseOrderId,
    required this.productId,
    required this.quantityOrder,
    required this.unitPrice,
  });

  factory PurchaseOrderItem.fromSqfliteDataBase(Map<String, dynamic> map) {
    return PurchaseOrderItem(
      purchaseOrderItemId: map['purchase_order_item_id']?.toInt() ?? 0,
      purchaseOrderId: map['purchase_order_id']?.toInt() ?? 0,
      productId: map['product_id']?.toInt() ?? 0,
      quantityOrder: map['quantity_order']?.toInt() ?? 0,
      unitPrice: map['unit_price']?.toDouble() ?? 0.0,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'purchase_order_item_id': purchaseOrderItemId,
      'purchase_order_id': purchaseOrderId,
      'product_id': productId,
      'quantity_order': quantityOrder,
      'unit_price': unitPrice,
    };
  }


  static Future<void> createPurchaseOrderItemTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tablePurchaseOrderItem (
        purchase_order_item_id INTEGER PRIMARY KEY AUTOINCREMENT,
        purchase_order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity_order INTEGER NOT NULL,
        unit_price REAL NOT NULL
      )
    ''');
  }


  static Future<void> dropPurchaseOrderItemTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tablePurchaseOrderItem');
  }

  static Future<List<PurchaseOrderItem>> getAllPurchaseOrderItems(Database db) async {
    final List<Map<String, dynamic>> maps = await db.query(tablePurchaseOrderItem);
    return List.generate(maps.length, (i) {
      return PurchaseOrderItem.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<void> insertPurchaseOrderItem(Database db, PurchaseOrderItem purchaseOrderItem) async {
    await db.insert(
      tablePurchaseOrderItem,
      purchaseOrderItem.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  static Future<void> updatePurchaseOrderItem(Database db, PurchaseOrderItem purchaseOrderItem) async {
    await db.update(
      tablePurchaseOrderItem,
      purchaseOrderItem.toJson(),
      where: 'purchase_order_item_id = ?',
      whereArgs: [purchaseOrderItem.purchaseOrderItemId],
    );
  }

  static Future<void> deletePurchaseOrderItem(Database db, int purchaseOrderItemId) async {
    await db.delete(
      tablePurchaseOrderItem,
      where: 'purchase_order_item_id = ?',
      whereArgs: [purchaseOrderItemId],
    );
  }


  static Future<PurchaseOrderItem?> getPurchaseOrderItemById(Database db, int purchaseOrderItemId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tablePurchaseOrderItem,
      where: 'purchase_order_item_id = ?',
      whereArgs: [purchaseOrderItemId],
    );

    if (maps.isNotEmpty) {
      return PurchaseOrderItem.fromSqfliteDataBase(maps.first);
    } else {
      return null;
    }
  }

  static Future<List<PurchaseOrderItem>> getPurchaseOrderItemsByPurchaseOrderId(Database db, int purchaseOrderId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tablePurchaseOrderItem,
      where: 'purchase_order_id = ?',
      whereArgs: [purchaseOrderId],
    );
    return List.generate(maps.length, (i) {
      return PurchaseOrderItem.fromSqfliteDataBase(maps[i]);
    });
  }


  static Future<List<PurchaseOrderItem>> getPurchaseOrderItemsByProductId(Database db, int productId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tablePurchaseOrderItem,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    return List.generate(maps.length, (i) {
      return PurchaseOrderItem.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<void> deletePurchaseOrderItemsByPurchaseOrderId(Database db, int purchaseOrderId) async {
    await db.delete(
      tablePurchaseOrderItem,
      where: 'purchase_order_id = ?',
      whereArgs: [purchaseOrderId],
    );
  }

  static Future<void> deletePurchaseOrderItemsByProductId(Database db, int productId) async {
    await db.delete(
      tablePurchaseOrderItem,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  static Future<void> deletePurchaseOrderItemsByProductIdAndPurchaseOrderId(Database db, int productId, int purchaseOrderId) async {
    await db.delete(
      tablePurchaseOrderItem,
      where: 'product_id = ? AND purchase_order_id = ?',
      whereArgs: [productId, purchaseOrderId],
    );
  }
}
