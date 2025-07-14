import 'dart:async';

import 'package:pos_desktop_loop/db/tables/business_table.dart';
import 'package:pos_desktop_loop/db/tables/categories_table.dart';
import 'package:pos_desktop_loop/db/tables/costomer_table.dart';
import 'package:pos_desktop_loop/db/tables/product/product_order_item_table.dart';
import 'package:pos_desktop_loop/db/tables/product/products_table.dart';
import 'package:pos_desktop_loop/db/tables/purchase_order.dart';
import 'package:pos_desktop_loop/db/tables/report/shop_stock_summary_table.dart';
import 'package:pos_desktop_loop/db/tables/report/stock_reorder_report_table.dart';
import 'package:pos_desktop_loop/db/tables/report/stock_valuation_report_table.dart';
import 'package:pos_desktop_loop/db/tables/shop/shop_order_item.dart';
import 'package:pos_desktop_loop/db/tables/shop/shop_table.dart';
import 'package:pos_desktop_loop/db/tables/stock/inventory_table.dart';
import 'package:pos_desktop_loop/db/tables/supplier_table.dart';
import 'package:pos_desktop_loop/db/tables/tax_category_table.dart';
import 'package:pos_desktop_loop/db/tables/user_table.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

class DatabaseHelper {
  Database? _database;
  // create sql database
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB();
    return _database!;
  }

  Future<String> fullPath() async {
    const name = 'pos_database.db';
    final dbPath = await sql.getDatabasesPath();
    return dbPath + name;
  }

  Future<Database> _initDB() async {
    final path = await fullPath();
    return await sql.openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      singleInstance: true,
      onUpgrade: _onUpgrade,
    );
  }

  // create tables
  // create queries

  Future<void> _createDB(Database db, int version) async {
    await UserTable.createUserProfileTable(db);
    await ProductsTable.createProductsTable(db);
    await CategoriesTable.createCategoriesTable(db);
    await TaxCategoryTable.createTaxCategoryTable(db);
    // await PurchaseOrderItem.createPurchaseOrderItemTable(db);
    // await ShopStockSummaryTable.createShopStockSummaryTable(db);
    // await StockValuationReportTable.createStockValuationReportTable(db);
    await ShopTable.createShopTable(db);
    await SupplierTable.createSupplierTable(db);
    await PurchaseOrderTable.createPurchaseOrderTable(db);
    await InventoryTable.createInventoryTable(db);
    await CustomerTable.createCustomerTable(db);
    await Business.createBusinessTable(db);
    // await ShopOrderItemTable.createShopOrderItemTable(db);
    // await StockReorderReportTable.createStockReorderReportTable(db);
  }

  // on upgrade
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await UserTable.createUserProfileTable(db);
      await ProductsTable.createProductsTable(db);
      await CategoriesTable.createCategoriesTable(db);
      await TaxCategoryTable.createTaxCategoryTable(db);
      // await PurchaseOrderItem.createPurchaseOrderItemTable(db);
      // await ShopStockSummaryTable.createShopStockSummaryTable(db);
      // await StockValuationReportTable.createStockValuationReportTable(db);
      await ShopTable.createShopTable(db);
      await SupplierTable.createSupplierTable(db);
      await PurchaseOrderTable.createPurchaseOrderTable(db);
      await InventoryTable.createInventoryTable(db);
      await CustomerTable.createCustomerTable(db);
      await Business.createBusinessTable(db);
      // await ShopOrderItemTable.createShopOrderItemTable(db);
      // await StockReorderReportTable.createStockReorderReportTable(db);
      (db);

      await _createDB(db, newVersion);
    }
  }

  Future<void> updateDatabaseSchema() async {
    // Check for new tables and update schema accordingly
    if (!await tableExists(tableUsers)) {
      final db = await _initDB();
      await UserTable.createUserProfileTable(db);
      await ProductsTable.createProductsTable(db);
      await CategoriesTable.createCategoriesTable(db);
      await TaxCategoryTable.createTaxCategoryTable(db);
      await PurchaseOrderItem.createPurchaseOrderItemTable(db);
      await ShopStockSummaryTable.createShopStockSummaryTable(db);
      await StockValuationReportTable.createStockValuationReportTable(db);
      await ShopTable.createShopTable(db);
      await SupplierTable.createSupplierTable(db);
      await PurchaseOrderTable.createPurchaseOrderTable(db);
      await InventoryTable.createInventoryTable(db);
      await ShopOrderItemTable.createShopOrderItemTable(db);
      await StockReorderReportTable.createStockReorderReportTable(db);
      await CustomerTable.createCustomerTable(db);
      await Business.createBusinessTable(db);
    }

    //

    // ... Add logic for other new tables
  }

  Future<bool> tableExists(String table) async {
    // Add logic to check if table exists
    final db = await _initDB();
    final result = await db.query(
      'sqlite_master',
      where: 'type = ? AND name = ?',
      whereArgs: ['table', table],
    );
    return result.isNotEmpty;
  }
}
