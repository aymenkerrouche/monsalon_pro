import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:monsalon_pro/Views/Auth/SignUp.dart';
import 'package:monsalon_pro/Views/Home/Home.dart';
import 'package:monsalon_pro/theme/colors.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Provider/AuthProvider.dart';
import '../../Provider/UserProvider.dart';
import '../../Widgets/SnaKeBar.dart';
import '../../main.dart';
import '../../widgets/keyboard.dart';
import '../../widgets/phone TextField.dart';
import '../account/UpdateProfileScreen.dart';
import 'package:monsalon_pro/models/User.dart' as us;

class AuthOTP extends StatelessWidget {
  const AuthOTP({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(onTap: () {FocusScope.of(context).unfocus();KeyboardUtil.hideKeyboard(context);},
      child: Scaffold(
        backgroundColor: background,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(backgroundColor: background,toolbarHeight: 20,),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          height: size.height,
          width: size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20,),

                      Container(
                        height: 100,
                        padding: const EdgeInsets.only(right: 5,top: 5,bottom: 5),
                        child: Image.asset('assets/images/logo.png',color: primaryPro,),
                      ),
                      const Text("Connectez-vous", style: TextStyle(color: primaryPro,fontWeight: FontWeight.w700,fontSize: 24,letterSpacing: 1),),

                      const SizedBox(height: 10,),
                      SizedBox(width: size.width * 0.7,child: const FittedBox(child: Text( "Saisir votre numéro télephone", style: TextStyle(color: Colors.black),))),

                      const SizedBox(height: 40,),

                      const OTP(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25,),
              const Text("En vous connectant à MonSalon Pro vous acceptez les", textAlign: TextAlign.center,style: TextStyle(fontSize: 13)),
              InkWell(
                onTap: () async {
                  final Uri url = Uri.parse("https://monsalon-dz.com/cgu");
                  await launchUrl(url,mode: LaunchMode.externalApplication);
                },
                child: const Text("conditions d'utilisation",
                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 15,),
            ],
          ),
        ),
      ),
    );
  }
}

class OTP extends StatefulWidget {
  const OTP({Key? key}) : super(key: key);

  @override
  State<OTP> createState() => _OTPState();
}

class _OTPState extends State<OTP> {

  bool sms = false;
  bool clicked = false;
  static bool isExpert = false;

  double salonAlign = -1;
  double expertAlign = 1;
  Color selectedColor = Colors.white;
  Color normalColor = Colors.black54;
  double? xAlign;
  Color? salon;
  Color? expert;

  TextEditingController phoneController = TextEditingController();
  TextEditingController verificationIdController = TextEditingController();
  TextEditingController codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    xAlign = salonAlign;
    salon = selectedColor;
    expert = normalColor;
  }

  @override
  void dispose() {
    phoneController.dispose();
    verificationIdController.dispose() ;
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: sms ? buildPhoneNumberFormField(codeController,"Code","Saisir le code"):
            buildPhoneNumberFormField(phoneController,"phone","05 -- -- -- --"),
          ),

          const SizedBox(height: 25,),
          Container(
            width: size.width,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xffe5e5e5ff),
              borderRadius: BorderRadius.all(Radius.circular(14.0),),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  alignment: Alignment(xAlign!, 0),
                  duration: const Duration(milliseconds: 100),
                  child: Container(
                    width: size.width * 0.45,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.all(
                        Radius.circular(14.0),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      xAlign = salonAlign;
                      isExpert = false;
                    });
                    Timer(const Duration(milliseconds: 90),(){
                      setState(() {
                        expert = normalColor;
                        salon = selectedColor;
                      });
                    });
                  },
                  child: Align(
                    alignment: const Alignment(-1, 0),
                    child: Container(
                      width: size.width * 0.45,
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      child: Text(
                        'Salon',
                        style: TextStyle(
                          color: salon,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      xAlign = expertAlign;
                      isExpert = true;
                    });
                    Timer(const Duration(milliseconds: 90),(){
                      setState(() {
                        expert = selectedColor;
                        salon = normalColor;
                      });
                    });
                  },
                  child: Align(
                    alignment: const Alignment(1, 0),
                    child: Container(
                      width: size.width * 0.45,
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      child: Text(
                        'Expert',
                        style: TextStyle(
                          color: expert,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 100,),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                foregroundColor: Colors.white,
                fixedSize: Size(size.width, 50),
                backgroundColor: primary,
                elevation: 10
            ),
            onPressed: () async {
              KeyboardUtil.hideKeyboard(context);

              if(phoneController.text.isNotEmpty){
                if(sms == false){
                  if(phoneController.text.startsWith("0")){
                    phoneController.text = "+213 ${phoneController.text.substring(1,phoneController.text.length)}";
                  }
                  if(phoneController.text.startsWith("5") || phoneController.text.startsWith("6") ||phoneController.text.startsWith("7")){
                    phoneController.text = "+213 ${phoneController.text}";
                  }
                  if(phoneController.text.startsWith("213")){
                    phoneController.text = "+${phoneController.text}";
                  }

                  EasyLoading.show(status: 'Envoi sms');

                  await FirebaseAuth.instance.verifyPhoneNumber(
                    phoneNumber: phoneController.text,

                    verificationCompleted: (PhoneAuthCredential credential) async {
                      //EasyLoading.showSuccess('Bienvenue');
                      //await FirebaseAuth.instance.signInWithCredential(credential);
                    },

                    verificationFailed: (e) {
                      EasyLoading.dismiss();
                      final snackBar = snaKeBar("${e.message}",);
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },

                    codeAutoRetrievalTimeout: (String verificationId) {},

                    codeSent: ((String verificationId, int? resendToken) async {
                      verificationIdController.text = verificationId;
                      EasyLoading.dismiss();
                      setState(() {sms = true;});
                    }),
                  );
                }
                else{
                  if(codeController.text.isNotEmpty){
                    setState(() {clicked = true;});
                    PhoneAuthCredential credential = PhoneAuthProvider.credential(
                      verificationId: verificationIdController.text,
                      smsCode: codeController.text,
                    );
                    await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {

                      if(isExpert == true){
                        await prefs?.setBool("expertMode", true);

                        await FirebaseFirestore.instance.collection("users").doc(value.user?.uid).get().then((snapshot) async {

                          // SIGN UP
                          if(!snapshot.exists){
                            await FirebaseFirestore.instance.collection("users").doc(value.user?.uid).set({"phone": phoneController.text,"expert":true,"token":await FirebaseMessaging.instance.getToken()}).then((value){
                              EasyLoading.dismiss();
                              Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (BuildContext context) => const UpdateProfileScreen(isSignUP: true,)), (Route<dynamic> route) => false);
                            });
                          }

                          // SIGN IN
                          else{
                            if(value.user != null){
                              await FirebaseFirestore.instance.collection("user").doc(value.user?.uid).update({"token":await FirebaseMessaging.instance.getToken()}).then((value){
                                EasyLoading.dismiss();
                                Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (BuildContext context) => const HomePage()), (Route<dynamic> route) => false);}
                              );
                            }
                          }

                        });
                      }
                      else{
                        await prefs?.setBool("expertMode", false);
                        await FirebaseFirestore.instance.collection("salon").doc(value.user?.uid).get().then((snapshot) async {

                          // SIGN UP
                          if(!snapshot.exists){
                            EasyLoading.dismiss();
                            await FirebaseFirestore.instance.collection("salon").doc(value.user?.uid).set({"phone": phoneController.text,"visible":false,"token":await FirebaseMessaging.instance.getToken()}).then((value) =>
                                Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (BuildContext context) => const SignUpScreen()), (Route<dynamic> route) => false));
                          }

                          // SIGN IN
                          else{
                            if(value.user != null){
                              await FirebaseFirestore.instance.collection("salon").doc(value.user?.uid).update({"token":await FirebaseMessaging.instance.getToken()}).then((value){
                                EasyLoading.dismiss();
                                Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (BuildContext context) => const HomePage()), (Route<dynamic> route) => false);}
                              );
                              EasyLoading.dismiss();
                            }
                          }

                        });
                      }

                    })
                    .catchError((erreur){
                      EasyLoading.dismiss();
                      setState(() {sms = false;clicked = false;});
                      debugPrint(erreur.toString());
                      final snackBar = snaKeBar("$erreur",);
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    });
                  }
                }
                setState(() {clicked = false;});
              }
              else{
                final snackBar = snaKeBar("Remplissez le champ");
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }

            },
            child: clicked ? const SizedBox(height: 20,width: 20,child: CircularProgressIndicator(color: Colors.white,strokeWidth: 3,),) : Text(
              sms ? "Saisissez le code" : "Envoyer",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),

          // OR
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Row(children: <Widget>[
              Expanded(
                child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: const Divider(
                      color: Colors.black,
                      height: 50,
                    )),
              ),
              const Text("Ou"),
              Expanded(
                child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: const Divider(
                      color: Colors.black,
                      height: 50,
                    )),
              ),
            ]),
          ),

          // GOOGLE
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: const BorderSide(color: Colors.black, width: 1),
              foregroundColor: primary,
              elevation: 16,
              fixedSize: Size(size.width , 50),
            ),
            onPressed: () {
              Timer(const Duration(milliseconds: 300), () async {

                final providerAuth = Provider.of<AuthProvider>(context, listen: false);
                KeyboardUtil.hideKeyboard(context);
                UserCredential? user;

                // AUTH
                try{EasyLoading.show();user = await providerAuth.signInWithGoogle();}
                catch(onError){
                  EasyLoading.dismiss();
                  final snackBar = snaKeBar("Vérifier votre connexion");
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }

                if(user?.user != null){

                  // EXPERT AUTH
                  if(isExpert == true){
                    await prefs?.setBool("expertMode", true);

                    await FirebaseFirestore.instance.collection("users").doc(user?.user?.uid).get().then((snapshot) async {

                      // SIGN UP
                      if(!snapshot.exists){
                        await FirebaseFirestore.instance.collection("users").doc(user?.user?.uid).set({"nom": user?.user?.displayName, "email": user?.user?.providerData.first.email,"expert":true,"token":await FirebaseMessaging.instance.getToken()}).then((value){
                          EasyLoading.dismiss();
                          Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (BuildContext context) => const UpdateProfileScreen(isSignUP: true,)), (Route<dynamic> route) => false);
                        });
                      }

                      // SIGN IN
                      else{
                        await FirebaseFirestore.instance.collection("user").doc(user?.user?.uid).update({"token":await FirebaseMessaging.instance.getToken()}).then((value){
                          EasyLoading.dismiss();
                          Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (BuildContext context) => const HomePage()), (Route<dynamic> route) => false);}
                        );
                      }

                    });
                  }

                  else{
                    await prefs?.setBool("expertMode", false);
                    await FirebaseFirestore.instance.collection("salon").doc(user?.user?.uid).get().then((snapshot) async {

                      // SIGN UP
                      if(!snapshot.exists){
                        await FirebaseFirestore.instance.collection("salon").doc(user?.user?.uid).set({"nom": user?.user?.displayName, "email": user?.user?.providerData.first.email,"visible":false,"token":await FirebaseMessaging.instance.getToken()}).then((value){
                          EasyLoading.dismiss();
                          Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (BuildContext context) => const SignUpScreen()), (Route<dynamic> route) => false);}
                        );
                      }

                      // SIGN IN
                      else{
                        await FirebaseFirestore.instance.collection("salon").doc(user?.user?.uid).update({"token":await FirebaseMessaging.instance.getToken()}).then((value){
                          EasyLoading.dismiss();
                          Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (BuildContext context) => const HomePage()), (Route<dynamic> route) => false);}
                        );
                      }

                    })
                    .catchError((onError){
                      debugPrint(onError.toString());
                      final snackBar = snaKeBar(onError.toString());
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      EasyLoading.dismiss();
                    });
                  }

                }
                EasyLoading.dismiss();
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/icons/google.svg",
                  height: 28,
                  width: 28,
                ),
                const SizedBox(width: 10,),
                SizedBox(
                  width: size.width * 0.55,
                  child: const FittedBox(
                    child: Text(
                      "Se connecter avec google",
                      style: TextStyle(color: Colors.black,fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

