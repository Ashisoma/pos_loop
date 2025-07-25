import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/db/controllers/local_find_service.dart';
import 'package:pos_desktop_loop/db/controllers/local_insert_service.dart';
import 'package:pos_desktop_loop/db/tables/costomer_table.dart';
import 'package:pos_desktop_loop/db/tables/supplier_table.dart';
import 'package:pos_desktop_loop/db/tables/user_table.dart';

class PeopleProvider with ChangeNotifier {
  final LocalFindService _localFindService = LocalFindService();

  List<CustomerTable> _customers = [];
  List<UserTable> _users = [];
  List<SupplierTable> _suppliers = [];

  List<CustomerTable> get customers => _customers;
  List<UserTable> get users => _users;
  List<SupplierTable> get suppliers => _suppliers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchPeopleData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _customers = await _localFindService.getAllCustomers();
      _suppliers = await _localFindService.getAllSuppliers();
      _users = await _localFindService.getAllUsers();
    } catch (e) {
      debugPrint('Error fetching people data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    await fetchPeopleData();
  }

  Future<void> deleteSupplier(int id) async {
    try {
      await LocalInsertService().deleteCustomerOrSupplier(id);
      await fetchPeopleData(); // Refresh data after deletion
    } catch (e) {
      debugPrint('Error deleting item: $e');
    }
  }

  Future<void> deleteCustomer(int id) async {
    try {
      await LocalInsertService().deleteCustomer(id);
      await fetchPeopleData(); // Refresh data after deletion
    } catch (e) {
      debugPrint('Error deleting item: $e');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await LocalInsertService().deleteUser(id);
      await fetchPeopleData(); // Refresh data after deletion
    } catch (e) {
      debugPrint('Error deleting item: $e');
    }
  }

  Future<int?> registerCustomer(CustomerTable customer) async {
    try {
      int? res = await LocalInsertService().registerCustomer(customer);
      await fetchPeopleData();
      return res; // Refresh data after deletion
    } catch (e) {
      debugPrint('Error deleting item: $e');
    }
    return 0;
  }

  Future<int?> registerSupplier(SupplierTable sup) async {
    try {
      int? res = await LocalInsertService().registerSupplier(sup);
      await fetchPeopleData(); // Refresh data after deletion
      return res!;
    } catch (e) {
      debugPrint('Error deleting item: $e');
    }
    return 0;
  }

  Future<bool> updateUserStatus(int userId, bool isActive) async {
    try {
      // Update status in database
      final rowsAffected = await UserTable.updateUserStatus(userId, isActive);

      if (rowsAffected != null && rowsAffected > 0) {
        // Update local state if database update was successful
        final userIndex = _users.indexWhere((user) => user.id == userId);
        if (userIndex != -1) {
          _users[userIndex] = _users[userIndex].copyWith(isActive: isActive);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating user status: $e');
      return false;
    }
  }

  // In your provider class (e.g., DataProvider.dart)
  List<UserTable> searchUsers(String query) {
    return users.where((user) {
      return user.fullName.toLowerCase().contains(query.toLowerCase()) ||
          user.email.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<CustomerTable> searchCustomers(String query) {
    return customers.where((customer) {
      return customer.name!.toLowerCase().contains(query.toLowerCase()) ||
          customer.phone!.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<SupplierTable> searchSuppliers(String query) {
    return suppliers.where((supplier) {
      return supplier.companyName!.toLowerCase().contains(
            query.toLowerCase(),
          ) ||
          supplier.contactPerson!.toLowerCase().contains(query.toLowerCase()) ||
          supplier.phone!.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
