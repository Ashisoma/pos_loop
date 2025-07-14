import 'package:pos_desktop_loop/db/controllers/helper_gen.dart';
import 'package:pos_desktop_loop/db/helpers/database_helper.dart';
import 'package:pos_desktop_loop/db/tables/shop/shop_table.dart';
import 'package:pos_desktop_loop/db/tables/user_table.dart';

class AuthService {
  // Register user
  static Future<int?> register(UserTable user) async {
    bool exists = await userExists(user.phoneNumber);
    if (exists) {
      return 0; // user already exists
    }
    return await insertUser(user);
  }

  // Login user
  static Future<UserTable?> login(String phone, String password) async {
    final db = await DatabaseHelper().database;
    List<Map<String, dynamic>> result = await db.query(
      tableUsers,
      where: 'phone_number = ? AND password = ?',
      whereArgs: [phone, password],
      limit: 1,
    );

    final token = HelperGen().generateUniqueToken();

    if (result.isNotEmpty) {
      // return the user object
      var user = UserTable.fromSqfliteDataBase(result.first);

      // generate a token and save it to the user
      UserTable.generateToken(token, user.id!);
      return user;
    }
    return null;
  }

  // Forgot password — update password by phone
  static Future<bool> resetPassword(String phone, String newPassword) async {
    final db = await DatabaseHelper().database;
    int updated = await db.update(
      tableUsers,
      {'password': newPassword},
      where: 'phone_number = ?',
      whereArgs: [phone],
    );
    return updated > 0;
  }

  // get current user
  Future<UserTable?> getCurrentUser() async {
    final db = await DatabaseHelper().database;
    List<Map<String, dynamic>> result = await db.query(
      tableUsers,
      where: 'token IS NOT NULL',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return UserTable.fromSqfliteDataBase(result.first);
    }
    return null;
  }

  // get current user and delete token as a logout function
  static Future<UserTable?> logout() async {
    final db = await DatabaseHelper().database;
    List<Map<String, dynamic>> result = await db.query(
      tableUsers,
      where: 'token IS NOT NULL',
      limit: 1,
    );

    if (result.isNotEmpty) {
      var user = UserTable.fromSqfliteDataBase(result.first);
      await deleteToken(user.id!);
      return user;
    }
    return null;
  }

  // Private helper methods (reuse your DB functions)
  static Future<int> insertUser(UserTable user) =>
      UserTable.insertUserProfile(user);
  static Future<bool> userExists(String phone) =>
      UserTable.userExistsLocal(phone);

  static Future<void> deleteToken(int id) => UserTable.deleteToken(id);
  static Future<void> updateUserProfile(UserTable user) =>
      UserTable.updateUserProfile(user);

  static Future<int?> assignUserToShop(int user, int shopId) async {
    return await ShopTable.setManagerId(user, shopId);
  }
}
