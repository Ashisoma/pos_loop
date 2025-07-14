import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class Expense {
  static const String _tableName = 'expenses';

  int? id;
  int businessId;
  String shopId;
  String type;
  double amount;
  DateTime date;
  String? notes;
  String? paymentMethod;
  DateTime createdAt;

  Expense({
    this.id,
    required this.businessId,
    required this.shopId,
    required this.type,
    required this.amount,
    required this.date,
    this.notes,
    this.paymentMethod = 'Cash',
    required this.createdAt,
  });

  // Convert Expense object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': businessId,
      'shop_id': shopId,
      'type': type,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create Expense object from a Map
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      businessId: map['business_id'],
      shopId: map['shop_id'],
      type: map['type'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      notes: map['notes'],
      paymentMethod: map['payment_method'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // Create the expenses table
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER NOT NULL,
        shop_id TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        payment_method TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // Insert a new expense
  static Future<int> insertExpense(Database db, Expense expense) async {
    return await db.insert(_tableName, expense.toMap());
  }

  // Get all expenses for a shop
  static Future<List<Expense>> getExpensesForShop(
    Database db, {
    required String businessId,
    required String shopId,
    DateTimeRange? dateRange,
  }) async {
    String where = 'business_id = ? AND shop_id = ?';
    List<dynamic> whereArgs = [businessId, shopId];

    if (dateRange != null) {
      where += ' AND date >= ? AND date <= ?';
      whereArgs.add(dateRange.start.toIso8601String());
      whereArgs.add(dateRange.end.toIso8601String());
    }

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  // Update an expense
  static Future<int> updateExpense(Database db, Expense expense) async {
    return await db.update(
      _tableName,
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // Delete an expense
  static Future<int> deleteExpense(Database db, int id) async {
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get total expenses for a period
  static Future<double> getTotalExpenses(
    Database db, {
    required String businessId,
    required String shopId,
    DateTimeRange? dateRange,
  }) async {
    String where = 'business_id = ? AND shop_id = ?';
    List<dynamic> whereArgs = [businessId, shopId];

    if (dateRange != null) {
      where += ' AND date >= ? AND date <= ?';
      whereArgs.add(dateRange.start.toIso8601String());
      whereArgs.add(dateRange.end.toIso8601String());
    }

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM $_tableName WHERE $where',
      whereArgs,
    );

    return result.first['total'] as double? ?? 0.0;
  }
}


  