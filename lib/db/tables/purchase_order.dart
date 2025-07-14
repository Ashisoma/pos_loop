import 'package:sqflite/sqflite.dart';

class PurchaseOrderTable {
  static const String tablePurchaseOrder = 'purchase_order';

  final String purchaseOrderId;
  final String supplierId;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final String status;

  PurchaseOrderTable({
    required this.purchaseOrderId,
    required this.supplierId,
    required this.orderDate,
    required this.deliveryDate,
    required this.status,
  });

  factory PurchaseOrderTable.fromSqfliteDataBase(Map<String, dynamic> map) {
    return PurchaseOrderTable(
      purchaseOrderId: map['purchase_order_id'] ?? '',
      supplierId: map['supplier_id'] ?? '',
      orderDate: DateTime.parse(map['order_date'] ?? DateTime.now().toString()),
      deliveryDate: DateTime.parse(map['delivery_date'] ?? DateTime.now().toString()),
      status: map['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'purchase_order_id': purchaseOrderId,
      'supplier_id': supplierId,
      'order_date': orderDate.toIso8601String(),
      'delivery_date': deliveryDate.toIso8601String(),
      'status': status,
    };
  }

  static Future<void> createPurchaseOrderTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tablePurchaseOrder (
        purchase_order_id TEXT PRIMARY KEY,
        supplier_id INT NOT NULL,
        order_date TEXT NOT NULL,
        delivery_date TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');
  }

  static Future<void> dropPurchaseOrderTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tablePurchaseOrder');
  }

  static Future<List<PurchaseOrderTable>> getAllPurchaseOrders(Database db) async {
    final List<Map<String, dynamic>> maps = await db.query(tablePurchaseOrder);
    return List.generate(maps.length, (i) {
      return PurchaseOrderTable.fromSqfliteDataBase(maps[i]);
    });
  }


  static Future<void> insertPurchaseOrder(Database db, PurchaseOrderTable purchaseOrder) async {
    await db.insert(
      tablePurchaseOrder,
      purchaseOrder.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updatePurchaseOrder(Database db, PurchaseOrderTable purchaseOrder) async {
    await db.update(
      tablePurchaseOrder,
      purchaseOrder.toJson(),
      where: 'purchase_order_id = ?',
      whereArgs: [purchaseOrder.purchaseOrderId],
    );
  }

  static Future<void> deletePurchaseOrder(Database db, String purchaseOrderId) async {
    await db.delete(
      tablePurchaseOrder,
      where: 'purchase_order_id = ?',
      whereArgs: [purchaseOrderId],
    );
  }

  static Future<PurchaseOrderTable?> getPurchaseOrderById(Database db, String purchaseOrderId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tablePurchaseOrder,
      where: 'purchase_order_id = ?',
      whereArgs: [purchaseOrderId],
    );

    if (maps.isNotEmpty) {
      return PurchaseOrderTable.fromSqfliteDataBase(maps.first);
    } else {
      return null;
    }
  }

  static Future<List<PurchaseOrderTable>> getPurchaseOrdersBySupplierId(Database db, String supplierId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tablePurchaseOrder,
      where: 'supplier_id = ?',
      whereArgs: [supplierId],
    );

    return List.generate(maps.length, (i) {
      return PurchaseOrderTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<List<PurchaseOrderTable>> getPurchaseOrdersByStatus(Database db, String status) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tablePurchaseOrder,
      where: 'status = ?',
      whereArgs: [status],
    );

    return List.generate(maps.length, (i) {
      return PurchaseOrderTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<void> deletePurchaseOrdersBySupplierId(Database db, String supplierId) async {
    await db.delete(
      tablePurchaseOrder,
      where: 'supplier_id = ?',
      whereArgs: [supplierId],
    );
  }

  static Future<void> deletePurchaseOrdersByStatus(Database db, String status) async {
    await db.delete(
      tablePurchaseOrder,
      where: 'status = ?',
      whereArgs: [status],
    );
  }
}