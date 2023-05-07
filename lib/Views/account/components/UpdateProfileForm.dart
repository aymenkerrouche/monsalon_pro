// ignore_for_file: curly_braces_in_flow_control_structures, avoid_returning_null_for_void, use_key_in_widget_constructors, non_constant_identifier_names, must_be_immutable
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/shimmer/gf_shimmer.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:getwidget/position/gf_toast_position.dart';
import 'package:monsalon_pro/Provider/UserProvider.dart';
import 'package:provider/provider.dart';
import '../../../Theme/colors.dart';
import '../../../utils/const.dart';
import '../../Home/Home.dart';
import 'package:monsalon_pro/models/User.dart' as us;

class UpdateProfileForm extends StatefulWidget {
  const UpdateProfileForm({super.key, this.isSignUP = false});
  final bool isSignUP;
  @override
  UpdateProfileFormState createState() => UpdateProfileFormState();
}

class UpdateProfileFormState extends State<UpdateProfileForm> {


  bool loading = false;

  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool done = false;

  Future<void> getInfos() async {
    try{
      await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser?.uid).get().then((snapshot){
        phoneController.text = snapshot.data()?['phone'] ?? '';
        emailController.text = snapshot.data()?['email'] ?? '';
        nameController.text = snapshot.data()?['name'] ?? '';
      })
      .whenComplete(() {
        if(FirebaseAuth.instance.currentUser!.email != null){
          emailController.text = FirebaseAuth.instance.currentUser!.email! ;
        }
        if(FirebaseAuth.instance.currentUser!.providerData.first.email != null){
          emailController.text = FirebaseAuth.instance.currentUser!.providerData.first.email!;
        }
        if(FirebaseAuth.instance.currentUser?.displayName != null){nameController.text = FirebaseAuth.instance.currentUser!.displayName!;}
        if(FirebaseAuth.instance.currentUser?.phoneNumber != null){phoneController.text = FirebaseAuth.instance.currentUser!.phoneNumber!;}
        Timer(const Duration(milliseconds: 700),(){setState(() {
          done =true;
        });});
      });
    }
    catch(e){
      debugPrint(e.toString());
    }
    Timer(const Duration(seconds: 5),(){
      if(done == false) {
        done = true;
        GFToast.showToast(
          'Internet Connection Problem', context, toastDuration: 3,
          backgroundColor: Colors.red.shade600,
          textStyle: const TextStyle(color: Colors.white),
          toastPosition: GFToastPosition.BOTTOM,
        );
      }
    });
  }

  @override
  void initState() {
    getInfos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return done == true ?
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormEmail(emailController: emailController,),
          const SizedBox(height: 40),
          SizedBox(height: 60,child: TextFormName(nameController: nameController,)),
          const SizedBox(height: 40),
          SizedBox(height: 60,child: TextFormPhone(phoneController: phoneController,)),
          const  SizedBox(height: 60),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: primary,
                  elevation: 4
              ),
              onPressed: () async {
                setState(() {loading = true;});
                try{
                  await updateUser();
                }
                on FirebaseAuthException catch(e){
                  GFToast.showToast(
                    e.code, context, toastDuration: 3,
                    backgroundColor: Colors.red.shade600,
                    textStyle: const TextStyle(color: Colors.white),
                    toastPosition: GFToastPosition.BOTTOM,
                  );
                }
                setState(() {loading = false;});
              },
              child: loading ?
              const SizedBox(height: 30,width: 30,child: CircularProgressIndicator(color: Colors.white,)):
              Text(widget.isSignUP ? "Sauvegarder" : "Mettre à jour", style:  const TextStyle(
                fontSize: 25,
                color: Colors.white,
              ),),
            ),
          ),
          const  SizedBox(height: 50),

        ],
      ):
      GFShimmer(
      mainColor: Colors.grey.shade50,
      child: Column(
        children: [
          buildShimmer(),
          SizedBox(height: size.height * 0.05),
          buildShimmer(),
          SizedBox(height: size.height * 0.05),
          buildShimmer(),
          SizedBox(height: size.height * 0.1),
          buildShimmer(),
        ],
      ),
    );
  }

  Widget buildShimmer(){
    return Container(height: 60, width: double.infinity, decoration: const BoxDecoration(color: Colors.white,borderRadius: BorderRadius.all(Radius.circular(20))));
  }

  Future<void> updateUser() async {

    // CHECK NAME
    if(nameController.text.isEmpty && phoneController.text.isNotEmpty){
      GFToast.showToast(
        "Le nom d'utilisateur est vide, veuillez entrer votre nom", context, toastDuration: 3,
        backgroundColor: Colors.red.shade600,
        textStyle: const TextStyle(color: Colors.white),
        toastPosition: GFToastPosition.BOTTOM,
      );
    }

    // CHECK PHONE
    if(nameController.text.isNotEmpty && phoneController.text.isEmpty){
      GFToast.showToast(
        "Veuillez entrer votre téléphone", context, toastDuration: 3,
        backgroundColor: Colors.red.shade600,
        textStyle: const TextStyle(color: Colors.white),
        toastPosition: GFToastPosition.BOTTOM,
      );
    }

    // CHECK BOTH
    if(nameController.text.isEmpty && phoneController.text.isEmpty){
      GFToast.showToast(
        "Veuillez saisir votre nom et téléphone", context, toastDuration: 3,
        backgroundColor: Colors.red.shade600,
        textStyle: const TextStyle(color: Colors.white),
        toastPosition: GFToastPosition.BOTTOM,
      );
    }

    // UPDATE
    if(nameController.text.isNotEmpty && phoneController.text.isNotEmpty){
      try{
        await FirebaseAuth.instance.currentUser?.updateDisplayName(nameController.text);
        await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).update({
          'phone': phoneController.text.trim(),
          'name': nameController.text.trim(),
          'email' : emailController.text.trim()
        })
        .then((v){
          if(widget.isSignUP){
            Provider.of<UserProvider>(context,listen: false).expert = us.User(FirebaseAuth.instance.currentUser!.uid, nameController.text, phoneController.text, emailController.text);
            Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (BuildContext context) => const HomePage()), (Route<dynamic> route) => false);
          }
          else{
            const snackBar = SnackBar(
              elevation: 10,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
              content: Text("Mise à jour du profil réussie", style: TextStyle(color: Colors.white),),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        });
      }
      on FirebaseAuthException catch (e) {
        GFToast.showToast(e.code, context,toastDuration: 3,backgroundColor: const TextStyle(color: Colors.red),textStyle: const TextStyle(color: Colors.white),toastPosition:GFToastPosition.BOTTOM,);
      }
    }

  }
}

class TextFormEmail extends StatelessWidget {
  TextFormEmail({Key? key, required this.emailController}) : super(key: key);
  TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 60,child: TextFormField(
      keyboardType: TextInputType.emailAddress,
      readOnly: FirebaseAuth.instance.currentUser!.phoneNumber != null ? false : true,
      controller: emailController,
      cursorColor: primary,
      style: const TextStyle(fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: "Email",
        hintText: "Entrez votre email",
        labelStyle: const TextStyle(color: primary),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: const Icon(Icons.email_rounded, color: primary),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: outlineInputBorder(),
        focusedBorder: inputBorder(),
        enabledBorder: outlineInputBorder(),
        hintStyle: const TextStyle(fontWeight: FontWeight.w400),
      ),
    ));
  }
}

class TextFormName extends StatelessWidget {
  TextFormName({Key? key, required this.nameController}) : super(key: key);
  TextEditingController nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 60,child: TextFormField(
      controller: nameController,
      cursorColor: primary,
      style: const TextStyle(fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: "Nom",
        hintText: "Entrez votre nom",
        labelStyle:  const TextStyle(color: primary),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: const Icon(
          Icons.person,
          color: primary,
        ),
        hintStyle: const TextStyle(fontWeight: FontWeight.w400),
        border: outlineInputBorder(),
        focusedBorder: inputBorder(),
        enabledBorder: outlineInputBorder(),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    ));
  }
}

class TextFormPhone extends StatelessWidget {
  TextFormPhone({Key? key, required this.phoneController}) : super(key: key);
  TextEditingController phoneController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 60,child: TextFormField(
      keyboardType: TextInputType.phone,
      controller: phoneController,
      readOnly: FirebaseAuth.instance.currentUser!.phoneNumber != null  ? true : false,
      cursorColor: primary,
      scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      style: const TextStyle(fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: "Téléphone",
        hintText: "Entrez votre numéro de téléphone",
        labelStyle:  const TextStyle(color: primary),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: const Icon(
          Icons.phone_rounded,
          color: primary,
        ),
        hintStyle: const TextStyle(fontWeight: FontWeight.w400),
        border: outlineInputBorder(),
        focusedBorder: inputBorder(),
        enabledBorder: outlineInputBorder(),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    ));
  }
}

