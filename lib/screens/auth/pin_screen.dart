import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/screens/home/home_screen.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String input = "";

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
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: width * 0.05, top: height * 0.1),

              child: SizedBox(
                child: Text(
                  'PIN',
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(right: width * 0.1, top: height * 0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: width * 0.3,
                    height: height * 0.6,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Form(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: width * 0.3,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                input,
                                style: TextStyle(fontSize: 32),
                              ),
                            ),
                            SizedBox(height: height * 0.02),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                for (var i = 1; i <= 3; i++)
                                  buildButton('$i', () => onKeyPress('$i')),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                for (var i = 4; i <= 6; i++)
                                  buildButton('$i', () => onKeyPress('$i')),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                for (var i = 7; i <= 9; i++)
                                  buildButton('$i', () => onKeyPress('$i')),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildButton('C', onClear),
                                buildButton('0', () => onKeyPress('0')),

                                buildButton('⌫', onBackspace),
                              ],
                            ),
                            const SizedBox(height: 20),

                            SizedBox(height: height * 0.02),
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
                                width: width * 0.4,
                                child: const Text(
                                  'Set Up PIN',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.02),
                            // GestureDetector(
                            //   onTap: () {
                            //     // Navigate to the forgot password screen
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder:
                            //             (context) => const ForgotPassScreen(),
                            //       ),
                            //     );
                            //   },
                            //   child: const Text(
                            //     // 'Dont have an account? Get started',
                            //     textAlign: TextAlign.end,
                            //     style: TextStyle(
                            //       color: Colors.black,

                            //       fontSize: 16,
                            //       fontWeight: FontWeight.w400,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onKeyPress(String value) {
    setState(() {
      input += value;
    });
  }

  void onClear() {
    setState(() {
      input = "";
    });
  }

  void onBackspace() {
    setState(() {
      if (input.isNotEmpty) {
        input = input.substring(0, input.length - 1);
      }
    });
  }

  Widget buildButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: Size(70, 70),
          backgroundColor: Colors.white,
        ),
        child: Text(text, style: TextStyle(fontSize: 24, color: Colors.black)),
      ),
    );
  }
}
