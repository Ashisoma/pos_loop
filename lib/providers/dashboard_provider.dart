import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/db/controllers/local_authentication_service.dart';

class DashboardData {
  final String userName;
  final Map<String, String> paymentMethods;
  final Map<String, String> stockSummary;
  final Map<String, String> financialOverview;
  final List<Map<String, dynamic>> topCategories;
  final List<Map<String, dynamic>> topProducts;
  final List<ChartData> salesChartData;

  DashboardData({
    required this.userName,
    required this.paymentMethods,
    required this.stockSummary,
    required this.financialOverview,
    required this.topCategories,
    required this.topProducts,
    required this.salesChartData,
  });
}

class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}

class DashboardProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  DashboardData _dashboardData = DashboardData(
    userName: 'User',
    paymentMethods: {
      'Cash': '25,365',
      'Bank': '10,065',
      'Mpesa': '34,500',
      'Owing': '3,000',
      'Owed': '5,000',
      'Cash Pool': '25,000',
    },
    stockSummary: {
      'Total Products': '768',
      'Total Products in Stock': '768',
      'Total Stock Value': 'Ksh 76,800',
    },
    financialOverview: {
      'Money In': '25,365',
      'Money Out': '10,065',
      'Cash Flow': '34,500',
      'Gross Profit': '3,000',
      'Net Profit': '25,000',
    },
    topCategories: [
      {'name': 'Braids', 'value': 120},
      {'name': 'Shirts', 'value': 95},
      {'name': 'Pants', 'value': 80},
      {'name': 'Shoes', 'value': 65},
    ],
    topProducts: [
      {'name': 'Polo Blue Shirt', 'value': 45},
      {'name': 'Black Jeans', 'value': 38},
      {'name': 'White Sneakers', 'value': 32},
      {'name': 'Red Dress', 'value': 28},
    ],
    salesChartData: [
      ChartData('Mpesa', 35),
      ChartData('Bank', 28),
      ChartData('Cash', 34),
      ChartData('Others', 40),
    ],
  );

  DashboardData get dashboardData => _dashboardData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch user data
      final user = await _authService.getCurrentUser();
      
      // Here you would typically fetch other data from your database/API
      // For now, we'll just update the user name
      _dashboardData = DashboardData(
        userName: user?.fullName ?? 'User',
        paymentMethods: _dashboardData.paymentMethods,
        stockSummary: _dashboardData.stockSummary,
        financialOverview: _dashboardData.financialOverview,
        topCategories: _dashboardData.topCategories,
        topProducts: _dashboardData.topProducts,
        salesChartData: _dashboardData.salesChartData,
      );
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
      // You might want to handle errors here
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to update payment method data
  void updatePaymentMethod(String method, String value) {
    _dashboardData.paymentMethods[method] = value;
    notifyListeners();
  }

  // Method to update stock summary
  void updateStockSummary(String key, String value) {
    _dashboardData.stockSummary[key] = value;
    notifyListeners();
  }

  // Method to update financial overview
  void updateFinancialOverview(String key, String value) {
    _dashboardData.financialOverview[key] = value;
    notifyListeners();
  }
}