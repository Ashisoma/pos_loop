import 'package:pos_desktop_loop/db/helpers/database_helper.dart';
import 'package:sqflite/sqflite.dart';

final String tableUsers = 'users_table';

class UserTable {
  final int? id;
  final String fullName;
  final String phoneNumber;
  final String password;
  final String? pinCode;
  final String email;
  final String? token;
  final String? role;
  final int? sync;
  final bool isActive;

  UserTable({
    this.token,
    this.pinCode,
    required this.password,
    this.id,
    this.role,
    required this.fullName,
    required this.phoneNumber,
    this.sync,
    required this.isActive,
    required this.email,
  });

  // Add the copyWith method here
  UserTable copyWith({
    int? id,
    String? fullName,
    String? phoneNumber,
    String? password,
    String? pinCode,
    String? email,
    String? token,
    String? role,
    int? sync,
    bool? isActive,
  }) {
    return UserTable(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      pinCode: pinCode ?? this.pinCode,
      email: email ?? this.email,
      token: token ?? this.token,
      role: role ?? this.role,
      sync: sync ?? this.sync,
      isActive: isActive ?? this.isActive,
    );
  }

  factory UserTable.fromSqfliteDataBase(Map<String, dynamic> map) {
    return UserTable(
      id: map['id']?.toInt() ?? 0,
      fullName: map['name'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? '',
      token: map['token'] ?? '',
      sync: map['sync'] ?? 0,
      email: map['email'] ?? '',
      isActive: map['isActive'] == 1,
      pinCode: map['pin_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': fullName,
      'phone_number': phoneNumber,
      'password': password,
      'pin_code': pinCode,
      'role': role,
      'email': email,
      'token': token,
      'isActive': isActive ? 1 : 0, // Convert boolean to 1/0 for database
      'sync': sync,
    };
  }

  static Future<void> createUserProfileTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableUsers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(150) NOT NULL,
        phone_number VARCHAR(100) NOT NULL,
        pin_code VARCHAR(100),
        password VARCHAR(100) NOT NULL,
        role VARCHAR(50) NOT NULL,
        email VARCHAR(150) NOT NULL,
        token VARCHAR(200), 
        isActive INTEGER DEFAULT 1,  -- Changed to store as integer (1=true, 0=false)
        sync INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  static Future<int> insertUserProfile(UserTable user) async {
    Database db = await DatabaseHelper().database;
    await db.insert(tableUsers, user.toJson());
    return await db
        .query(tableUsers, columns: ['id'], orderBy: 'id DESC', limit: 1)
        .then((value) => value[0]['id'] as int);
  }

  static Future<bool> userExistsLocal(String phone) async {
    Database db = await DatabaseHelper().database;
    List<Map<String, dynamic>> farmer = await db.query(
      tableUsers,
      where: 'phone_number = ?',
      whereArgs: [phone],
      limit: 1,
    );
    return farmer.isNotEmpty;
  }

  static Future<void> dropTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableUsers');
  }

  static Future<List<UserTable>> getAllUsers() async {
    Database db = await DatabaseHelper().database;
    List<Map<String, dynamic>> users = await db.query(tableUsers);
    return users.map((e) => UserTable.fromSqfliteDataBase(e)).toList();
  }

  static Future<int?> updateUserProfile(UserTable user) async {
    Database db = await DatabaseHelper().database;
    return await db.update(
      tableUsers,
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Updated to use boolean parameter but store as integer
  static Future<int?> updateUserStatus(int userId, bool isActive) async {
    Database db = await DatabaseHelper().database;
    return await db.update(
      tableUsers,
      {'isActive': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  static Future<void> generateToken(String token, int id) async {
    Database db = await DatabaseHelper().database;
    await db.update(
      tableUsers,
      {'token': token},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteToken(int id) async {
    Database db = await DatabaseHelper().database;
    await db.update(
      tableUsers,
      {'token': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<UserTable?> getUserById(int id) async {
    Database db = await DatabaseHelper().database;
    List<Map<String, dynamic>> users = await db.query(
      tableUsers,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (users.isNotEmpty) {
      return UserTable.fromSqfliteDataBase(users[0]);
    }
    return null;
  }

  static Future<int> deleteUser(int userId) async {
    Database db = await DatabaseHelper().database;
    return await db.delete(tableUsers, where: 'id = ?', whereArgs: [userId]);
  }
}
