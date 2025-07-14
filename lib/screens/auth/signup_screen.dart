import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/controllers/local_authentication_service.dart';
import 'package:pos_desktop_loop/db/tables/business_table.dart';
import 'package:pos_desktop_loop/db/tables/user_table.dart';
import 'package:pos_desktop_loop/screens/auth/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _visiblePassword = false;
  bool _visibleConfirm = false;

  final _phoneController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _businessNameController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _businessNameController.dispose();
    _fullNameController.dispose();
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
              SizedBox(height: size.height * 0.02),
              const Text(
                'Sign Up',
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
                      controller: _fullNameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                      enabled: !_isLoading,
                    ),
                    SizedBox(height: size.height * 0.02),
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
                        return null;
                      },
                      enabled: !_isLoading,
                    ),
                    SizedBox(height: size.height * 0.02),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'user@mail.com',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                          r"^[^@\s]+@[^@\s]+\.[^@\s]+$",
                        ).hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                      enabled: !_isLoading,
                    ),
                    SizedBox(height: size.height * 0.02),
                    TextFormField(
                      controller: _businessNameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: 'Business Name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your business name';
                        }
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
                          onPressed:
                              () => setState(
                                () => _visiblePassword = !_visiblePassword,
                              ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      enabled: !_isLoading,
                    ),
                    SizedBox(height: size.height * 0.02),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: !_visibleConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: '•••••••',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _visibleConfirm
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed:
                              () => setState(
                                () => _visibleConfirm = !_visibleConfirm,
                              ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      enabled: !_isLoading,
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
                        onPressed: _isLoading ? null : () => _registerUser(),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                )
                                : const Text(
                                  'Submit',
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
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                },
                        child: Text(
                          'Back to Login',
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

  void _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = UserTable(
        phoneNumber: _phoneController.text,
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: 'user',
        fullName: _fullNameController.text.trim(),
        sync: 0,
        isActive:
            true, // Add this line - new users should typically be active by default
      );
      int? res = await AuthService.register(user);

      if (res! > 0) {
        // Check if business name is provided
        if (_businessNameController.text.isNotEmpty) {
          final business = Business(
            businessName: _businessNameController.text.trim(),
            createdBy: user.fullName,
            createdAt: DateTime.now(),
          );
          await Business.insertBusiness(business);
        }
        // snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Registration successful. Please login to get started',
            ),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else if (res == 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User already exists')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: Server error $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
