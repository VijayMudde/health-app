import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Customize the background color
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',  // Path to the logo image
          width: 150,  // Adjust the width to your preference
        ),
      ),
    );
  }
}
