// app_initializer.dart

import 'package:pos_desktop_loop/db/demo_data.dart';
import 'package:pos_desktop_loop/shared_pref_init.dart';

class AppInitializer {
  static Future<void> initialize() async {
    // 1. Initialize database (creates tables)
    
    // 2. Check if first run
    if (await SharedPrefsService.isFirstRun()) {
      final demoData = DemoData();
      await demoData.insertAllDemoData();
      await SharedPrefsService.markAsInitialized();
    }
  }
}