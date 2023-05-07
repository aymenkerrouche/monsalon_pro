import 'package:flutter/material.dart';
import 'package:monsalon_pro/theme/colors.dart';
import 'components/body.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      extendBody: true,
      backgroundColor: primaryPro,
      body: const Body(),
    );
  }
}
