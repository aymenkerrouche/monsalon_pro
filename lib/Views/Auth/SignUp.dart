
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:monsalon_pro/Provider/AuthProvider.dart';
import 'package:monsalon_pro/Widgets/SnaKeBar.dart';
import 'package:provider/provider.dart';
import '../../Widgets/Wilaya.dart';
import '../../Widgets/keyboard.dart';
import '../../Widgets/phone TextField.dart';
import '../../theme/colors.dart';
import 'Maps.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(onTap: () {FocusScope.of(context).unfocus();KeyboardUtil.hideKeyboard(context);},
      child: Scaffold(
        backgroundColor: background,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Inscription",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 24)),
          backgroundColor: primary,
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          height: size.height,
          width: size.width,
          child: const BodySignUp()
        ),
      ),
    );
  }
}



class BodySignUp extends StatefulWidget {
  const BodySignUp({Key? key}) : super(key: key);
  @override
  State<BodySignUp> createState() => _BodySignUpState();
}

class _BodySignUpState extends State<BodySignUp> {

  TextEditingController salonNameController = TextEditingController();
  TextEditingController salonDescController = TextEditingController();
  TextEditingController salonPhoneController = TextEditingController();
  List gender=["Male","Female","Mix"];
  String selectGender = '';
  bool next = false;

  @override
  void initState() {
    Provider.of<AuthProvider>(context,listen: false).laWilaya.clear();
    Provider.of<AuthProvider>(context,listen: false).laCommune.clear();
    super.initState();
  }

  @override
  void dispose() {
    salonNameController.dispose();
    salonDescController.dispose();
    salonPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16,),
          const Text("Remplissez les informations", style: TextStyle(color: primaryPro,fontWeight: FontWeight.w700,fontSize: 20,letterSpacing: 1),maxLines: 3,),
          const SizedBox(height: 30,),

          TextInfomation(textController: salonNameController,label: "Nom",hint: "Salon de beauté",icon: Icons.business_sharp,textType: TextInputType.text),
          const SizedBox(height: 30,),

          if(FirebaseAuth.instance.currentUser?.phoneNumber == null)buildPhoneNumberFormField(salonPhoneController,"phone","05 -- -- -- --"),
          if(FirebaseAuth.instance.currentUser?.phoneNumber == null)const SizedBox(height: 30,),

          TextInfomation(textController: salonDescController,label: "Bio",hint: "Description",icon: Icons.description_outlined,maxLine:3,textType: TextInputType.text,),
          const SizedBox(height: 30,),

          const Wilaya(),
          const SizedBox(height: 20,),

          const Text("Sexe", style: TextStyle(color: primaryPro,fontWeight: FontWeight.w700,fontSize: 20,letterSpacing: 1)),
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              addRadioButton(0, 'Male'),
              addRadioButton(1, 'Female'),
              addRadioButton(2, 'Mix'),
            ],
          ),

          const SizedBox(height: 30,),
          Row(
            children: [
              TextButton(
                onPressed:() async {
                  setState(() {
                    salonNameController.clear();
                    salonDescController.clear() ;
                    salonPhoneController.clear() ;
                    selectGender = '';
                    Provider.of<AuthProvider>(context,listen: false).clearLaWilaya();
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: primaryLite,
                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                  elevation: 20,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)))
                ),
                child: const Text("Réinitialiser", style: TextStyle(color: primary ,fontWeight: FontWeight.w700,fontSize: 18,letterSpacing: 1,decoration: TextDecoration.underline,),),
              ),
              const Spacer(),
              TextButton(
                onPressed:() async {
                  setState(() {next = true;});

                  final auth = Provider.of<AuthProvider>(context,listen: false);

                  // NUM TELEPHONE
                  if(FirebaseAuth.instance.currentUser?.phoneNumber != null){
                    salonPhoneController.text = FirebaseAuth.instance.currentUser!.phoneNumber!;
                  }

                  // CREATION SALON
                  if(salonNameController.text.isNotEmpty && salonDescController.text.isNotEmpty && salonPhoneController.text.isNotEmpty && selectGender != '' && auth.laWilaya.text.isNotEmpty && auth.laCommune.text.isNotEmpty){

                    auth.fillSalon(salonNameController.text, salonDescController.text, selectGender,salonPhoneController.text);

                    // MAPS
                    Provider.of<AuthProvider>(context,listen: false).getMyLocation(context).then((v)=> Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen())));
                  }
                  // ERROR
                  else{
                    final snackBar = snaKeBar("Remplissez les informations de votre salon");
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }

                  setState(() {next = false;});

                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                  elevation: 20,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)))
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Continue",
                      style: TextStyle(color: Colors.white ,fontWeight: FontWeight.w700,fontSize: 18,letterSpacing: 1),),
                    const SizedBox(width: 10,),
                    next ? const SizedBox(height: 20,width: 20,child: CircularProgressIndicator(color: Colors.white,strokeWidth: 2.5,),) :
                    const Icon(Icons.arrow_forward_ios_rounded,size: 22,)
                  ],
                ),
              ),
              const SizedBox(width: 10,),
            ],
          ),
          const SizedBox(height: 20,),

          /*const SizedBox(height: 30,),
          Text(
            "Vous êtes",
            style: TextStyle(color: primaryPro,fontWeight: FontWeight.w700,fontSize: 24,letterSpacing: 1)),
          const SizedBox(height: 10,),
          Column(
            children: <Widget>[
              addCheckButton("Etablissement", 'Etablissement'),
              addCheckButton("Beauté à domicile", 'Beauté à domicile'),
            ],
          ),*/
        ],
      ),
    );
  }

  Widget addRadioButton(int btnValue, String title) {
    return StatefulBuilder(
      builder: (context, setInnerState) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Radio(
            activeColor: primary,
            value: gender[btnValue],
            groupValue: selectGender,
            onChanged: (value){
              setState(() {
                print(value);
                selectGender=value;
              });
            },
          ),
          Text(title)
        ],
      ),
    );
  }

  /*Column addCheckButton(String btnValue, String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        CheckboxListTile(
          activeColor: primary,
          value: type[btnValue],
          onChanged: (value){
            setState(() {
              print(value);
              type[btnValue] = value;
            });
          },
          title: Text(title),
        ),
      ],
    );
  }*/
}


