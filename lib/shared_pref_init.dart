// shared_prefs_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const String _firstRunKey = 'is_first_run';

  static Future<bool> isFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstRunKey) ?? true;
  }

  static Future<void> markAsInitialized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstRunKey, false);
  }
}