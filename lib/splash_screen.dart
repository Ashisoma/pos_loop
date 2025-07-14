import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pos_desktop_loop/db/controllers/local_authentication_service.dart';
import 'package:pos_desktop_loop/db/demo_data.dart';
import 'package:pos_desktop_loop/screens/auth/login_screen.dart';
import 'package:pos_desktop_loop/screens/home/home_screen.dart';
import 'package:pos_desktop_loop/shared_pref_init.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart'; // ✅ Add this import

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  bool _initializationComplete = false;
  bool _showSuccess = false;
  final authService = AuthService();

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    
    _progressAnimation = Tween(begin: 0.0, end: 1.0).animate(_progressController)
      ..addListener(() => setState(() {}));
    
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Start progress animation
    _progressController.forward();
    
    // Check if first run and initialize demo data
    if (await SharedPrefsService.isFirstRun()) {
      final demoData = DemoData();
      await demoData.insertAllDemoData();
      await SharedPrefsService.markAsInitialized();
    }

    // Complete initialization
    setState(() => _initializationComplete = true);
    
    // Show success state briefly
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _showSuccess = true);
    
    // Check auth status and navigate
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      final loggedIn = await authService.getCurrentUser() != null;
      _navigate(loggedIn);
    }
  }

  void _navigate(bool loggedIn) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => loggedIn ? const HomeScreen() : const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGreen.withOpacity(0.1),
              ),
            ),
          ),
          
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _showSuccess
                      ? Lottie.asset(
                          'assets/animations/check_mark.json',
                          width: 120,
                          height: 120,
                        )
                      : Lottie.asset(
                          'assets/animations/loading_lottie.json',
                          controller: _lottieController,
                          onLoaded: (composition) {
                            _lottieController
                              ..duration = composition.duration
                              ..forward();
                          },
                          width: 150,
                          height: 150,
                        ),
                ),

                const SizedBox(height: 40),

                // App name with fade-in effect
                AnimatedOpacity(
                  opacity: _progressAnimation.value > 0.3 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: const Text(
                    'POS PRO',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryGreen,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                AnimatedOpacity(
                  opacity: _progressAnimation.value > 0.5 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    'Business Management System',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Animated progress indicator
                SizedBox(
                  width: 250,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: Colors.grey.shade200,
                      color: _initializationComplete 
                          ? Colors.green 
                          : AppColors.primaryGreen,
                      minHeight: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Status text
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _showSuccess
                      ? Text(
                          'Ready to go!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryGreen,
                          ),
                        )
                      : Text(
                          _initializationComplete
                              ? 'Finalizing setup...'
                              : 'Initializing system... ${(_progressAnimation.value * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 14, 
                            color: Colors.grey.shade600
                          ),
                        ),
                ),
              ],
            ),
          ),
          
          // Version info at bottom
          Positioned(
            bottom: 30,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Text(
                  'Version 1.2.0 • © 2023 POS PRO',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}