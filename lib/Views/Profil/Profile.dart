import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:monsalon_pro/Theme/colors.dart';
import 'package:monsalon_pro/Views/Experts/Expert.dart';
import 'package:monsalon_pro/Views/Update/HoursUpdate.dart';
import 'package:monsalon_pro/Views/Update/PhotosUpdate.dart';
import 'package:provider/provider.dart';
import '../../Provider/AuthProvider.dart';
import '../../Widgets/profile_menu.dart';
import '../Auth/Maps.dart';
import '../Auth/authOTP.dart';
import '../Update/Informations.dart';
import '../Update/ServicesUpdate.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  bool bye = false;
  bool done = false;


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          "Paramètres",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.clip,
        ),
        backgroundColor: primary,
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.arrow_back_rounded,color: Colors.white,)),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: size.height,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //General
              const Padding(
                padding: EdgeInsets.only(left: 10,top: 30,bottom: 8),
                child: Text(
                  "Général",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 18),
                ),
              ),
              ProfileMenu(
                text: "Profil",
                icon: "assets/icons/user1.svg",
                press: () => Timer(const Duration(milliseconds: 150),()=>Navigator.push(context, CupertinoPageRoute(builder: (context) => const UpdateInformation()),)),
                primary: primary,
                secondary: clr3,
              ),
              ProfileMenu(
                text: "Horaires",
                icon: "assets/icons/history.svg",
                press: ()=>Timer(const Duration(milliseconds: 150),()=>Navigator.push(context, CupertinoPageRoute(builder: (context) => const UpdateHours()),)),
                width: 30,
                primary: primary,
                secondary: clr3,
              ),
              ProfileMenu(
                text: "Photos",
                icon: "assets/icons/category.svg",
                press: ()=>Timer(const Duration(milliseconds: 150),()=>Navigator.push(context, CupertinoPageRoute(builder: (context) => const UpdatePhotos()),)),
                primary: primary,
                secondary: clr3,
              ),
              ProfileMenu(
                text: "Services",
                icon: "assets/icons/cut.svg",
                press: ()=> Timer(const Duration(milliseconds: 150),()=>Navigator.push(context, CupertinoPageRoute(builder: (context) => const UpdateCategories()),)),
                primary: primary,
                secondary: clr3,
              ),
              ProfileMenu(
                text: "Experts",
                icon: "assets/icons/staff.svg",
                press: ()=> Timer(const Duration(milliseconds: 150),()=>Navigator.push(context, CupertinoPageRoute(builder: (context) => const ExpertScreen()),)),
                primary: primary,
                secondary: clr3,
              ),
              ProfileMenu(
                text: "Position GPS",
                icon: "assets/icons/location.svg",
                press: ()=> Timer(const Duration(milliseconds: 150),()=>Navigator.push(context, CupertinoPageRoute(builder: (context) => MapScreen(isUpdate: true,)),)),
                primary: primary,
                secondary: clr3,
              ),

              //FEEDBACK
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Feedback",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 18),
                ),
              ),
              ProfileMenu(
                text: "Centre d'aide",
                icon: "assets/icons/Question mark.svg",
                press: () {},
                primary: primary,
                secondary: clr3,
              ),
              ProfileMenu(
                text: "About us",
                icon: "assets/icons/Question mark.svg",
                press: () {},
                primary: primary,
                secondary: clr3,
              ),

              //LOG OUT
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Compte",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 18),
                ),
              ),
              ProfileMenu(
                text: "Se déconnecter",
                icon: "assets/icons/Logout.svg",
                press: () async {
                  if (!mounted) return;
                  setState(() {bye = true;});
                  Timer(const Duration(milliseconds: 400), () {
                    if (!mounted) return;
                    setState(() {done = true;});
                  });
                  Timer(const Duration(milliseconds: 1500), () {
                    if (!mounted) return;
                    setState(() {bye = false;});
                  });
                  Timer(const Duration(milliseconds: 1500), () async {

                    final providerAuth = Provider.of<AuthProvider>(context, listen: false);
                    switch(FirebaseAuth.instance.currentUser?.providerData.first.providerId) {
                      case 'google.com': {await providerAuth.googleLogOut();}
                      break;
                      default: {await providerAuth.logOut();}
                      break;
                    }
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const AuthOTP()), (route) => false);
                    if (!mounted) return;
                    setState(() {done = false;});

                  });
                },
                primary: primary,
                secondary: clr3,
                bye: bye,
              ),

              const SizedBox(height: 35,),

              //VERSION
              const Align(
                alignment: Alignment.center,
                child: Text(
                  "v 1.0.0 by Aymen Kerrouche",
                  style: TextStyle(
                      color: Colors.black26,
                      fontWeight: FontWeight.w400,
                      fontSize: 14
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: kBottomNavigationBarHeight+10,),
            ],
          ),
        ),
      ),
    );
  }
}
