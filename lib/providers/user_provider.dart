import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/db/controllers/local_authentication_service.dart';
import 'package:pos_desktop_loop/db/tables/user_table.dart';

class UserProvider extends ChangeNotifier {
  UserTable? _user;

  UserTable? get user => _user;

  bool isLoading = true;

  Future<void> loadUser() async {
    _user = await AuthService().getCurrentUser();
    isLoading = false;

    notifyListeners();
  }

  void updateUser(UserTable updatedUser) async {
    _user = updatedUser;
    await UserTable.updateUserProfile(updatedUser); 
    // update loading state
    isLoading = false;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
