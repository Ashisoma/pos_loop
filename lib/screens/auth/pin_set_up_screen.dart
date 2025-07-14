import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/screens/auth/forgot_pass_screen.dart';
import 'package:pos_desktop_loop/screens/auth/login_screen.dart';
import 'package:pos_desktop_loop/screens/home/home_screen.dart';

class PinSetUpScreen extends StatefulWidget {
  const PinSetUpScreen({super.key});

  @override
  State<PinSetUpScreen> createState() => _PinSetUpScreenState();
}

class _PinSetUpScreenState extends State<PinSetUpScreen> {
  var visiblePassword = false;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        height: height,
        width: width,
        padding: EdgeInsets.only(left: width * 0.04, right: width * 0.04),
        decoration: const BoxDecoration(color: Colors.white),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.2),
              Text(
                'Set Up Pin',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: height * 0.02),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          obscureText: visiblePassword,
                          maxLength: 4,
                          decoration: InputDecoration(
                            fillColor: Colors.grey[800],
                            focusColor: Colors.grey[800],
                            border: InputBorder.none,
                            labelText: 'PIN',
                            labelStyle: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                            ),
                            hintText: '****',
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  visiblePassword = !visiblePassword;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  visiblePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        TextFormField(
                          obscureText: visiblePassword,
                          maxLength: 4,
                          decoration: InputDecoration(
                            fillColor: Colors.grey[800],
                            focusColor: Colors.grey[800],
                            border: InputBorder.none,
                            labelText: 'CONFIRM PIN',
                            labelStyle: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                            ),
                            hintText: '****',
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  visiblePassword = !visiblePassword;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  visiblePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.04),
                        GestureDetector(
                          onTap: () {
                            // Navigate to the forgot password screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ForgotPassScreen(),
                              ),
                            );
                          },
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: const Text(
                              'Forgot Pin?',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: Colors.black,

                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.04),
                        GestureDetector(
                          onTap: () {
                            // Navigate to the home screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            width: width,
                            child: const Text(
                              'Submit',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.04),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to the forgot password screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Log in with password',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
