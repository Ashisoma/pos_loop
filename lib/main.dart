import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/controllers/local_authentication_service.dart';
import 'package:pos_desktop_loop/db/helpers/database_helper.dart';
import 'package:pos_desktop_loop/providers/inventory_provider.dart';
import 'package:pos_desktop_loop/providers/product_provider.dart';
import 'package:pos_desktop_loop/providers/user_provider.dart';
import 'package:pos_desktop_loop/providers/people_provider.dart';
import 'package:pos_desktop_loop/splash_screen.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // init the database
  await DatabaseHelper().updateDatabaseSchema();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => PeopleProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUser()),
        ChangeNotifierProvider(create: (_) => InventoryByShopProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'POS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final authService = AuthService();
  @override
  void initState() {
    super.initState();
    // Delay to ensure context is available
  }

  @override
  Widget build(BuildContext context) {
    // Show a splash/loading while checking auth state
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.accentDark),
      ),
    );
  }
}
