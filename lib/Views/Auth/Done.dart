// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monsalon_pro/Provider/CategoriesProvider.dart';
import 'package:monsalon_pro/Views/Auth/ChooseCategories.dart';
import 'package:monsalon_pro/Views/Home/Home.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';

class DoneScreen extends StatelessWidget {
  const DoneScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.1,),
            Center(child: SvgPicture.asset("assets/icons/barber.svg",width: size.width * 0.9,)),
            SizedBox(height: size.height * 0.05,),
            const Text("Bienvenue sur\nMON SALON Pro",
              style: TextStyle(fontSize: 28,color: Colors.black,fontWeight: FontWeight.w800),textAlign: TextAlign.start,
            ),
            const SizedBox(height: 20,),
            const Text("Vous avez créé le compte avec succès, complétez maintenant votre profil !",
              style: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w600),
            ),
            SizedBox(height: size.height * 0.1,),
            TextButton(
              onPressed:() async {
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const HomePage()), (Route<dynamic> route) => false);
              },
              style: TextButton.styleFrom(
                  backgroundColor: primary,
                  elevation: 20,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)))
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("  Continue", style: TextStyle(fontSize: 24,color: Colors.white,fontWeight: FontWeight.w600),),
                  SizedBox(width: 10,),
                  Icon(Icons.arrow_forward_rounded,size: 26,color: Colors.white,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
