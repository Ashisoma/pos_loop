import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/controllers/local_authentication_service.dart';
import 'package:pos_desktop_loop/db/tables/user_table.dart';
import 'package:pos_desktop_loop/screens/auth/forgot_pass_screen.dart';
import 'package:pos_desktop_loop/screens/auth/signup_screen.dart';
import 'package:pos_desktop_loop/screens/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _visiblePassword = false;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.2),
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '07** *** ***',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        // optional: add regex validation
                        return null;
                      },
                      enabled: !_isLoading,
                    ),
                    SizedBox(height: size.height * 0.02),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_visiblePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: '•••••••',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _visiblePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(
                              () => _visiblePassword = !_visiblePassword,
                            );
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      enabled: !_isLoading,
                    ),
                    SizedBox(height: size.height * 0.02),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed:
                            _isLoading
                                ? null
                                : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ForgotPassScreen(),
                                    ),
                                  );
                                },
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: _isLoading ? null : () => _loginUser(),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                )
                                : const Text(
                                  'Log in',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
                    Center(
                      child: TextButton(
                        onPressed:
                            _isLoading
                                ? null
                                : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SignupScreen(),
                                    ),
                                  );
                                },
                        child: Text(
                          'Don\'t have an account? Get started',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      UserTable? user = await AuthService.login(
        _phoneController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null && user.token != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User does not exist')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: \$e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
