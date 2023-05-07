import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    Key? key,
    required this.text,
    required this.icon,
    this.width = 22,
    this.press,
    required this.primary,
    required this.secondary,
    this.bye = false
  }) : super(key: key);

  final String text, icon;
  final VoidCallback? press;
  final double width;
  final Color primary;
  final Color secondary;
  final bool bye;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x1AE8E8E8),
            offset: Offset(0, 1),
            blurRadius: 1,
          )
        ]),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 18),
          shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: Colors.white,
          shadowColor: Colors.black12,
          elevation: 20,
        ),
        onPressed: press,
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              color: primary,
              width: width,
              height: 22,
            ),
            const SizedBox(width: 20),
            Expanded(child: Text(text,style: const TextStyle(fontSize: 18),)),
            bye ? SizedBox(height: 25,width: 25,child: CircularProgressIndicator(color: primary,strokeWidth: 3,)) :const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}
