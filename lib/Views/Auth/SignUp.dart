
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:monsalon_pro/Provider/AuthProvider.dart';
import 'package:provider/provider.dart';
import '../../Provider/CategoriesProvider.dart';
import '../../Widgets/Wilaya.dart';
import '../../Widgets/keyboard.dart';
import '../../theme/colors.dart';
import '../../widgets/phone TextField.dart';
import 'ChooseCategories.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(onTap: () {FocusScope.of(context).unfocus();KeyboardUtil.hideKeyboard(context);},
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Inscription",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 24)),
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
          const SizedBox(height: 10,),
          const Text("Remplissez les informations de votre salon", style: TextStyle(color: primaryPro,fontWeight: FontWeight.w700,fontSize: 24,letterSpacing: 1),maxLines: 3,),

          const SizedBox(height: 50,),

          TextInfomation(textController: salonNameController,label: "Nom de l'établissement",hint: "salon de beauté",icon: Icons.business_sharp,),
          const SizedBox(height: 30,),

          TextInfomation(textController: salonDescController,label: "Bio",hint: "description",icon: Icons.description_outlined,),
          const SizedBox(height: 30,),

          if(FirebaseAuth.instance.currentUser?.phoneNumber == null)buildPhoneNumberFormField(salonPhoneController,"phone","05 xx xx xx"),
          if(FirebaseAuth.instance.currentUser?.phoneNumber == null)const SizedBox(height: 30,),

          const Wilaya(),
          const SizedBox(height: 30,),

          const Text("Sexe", style: TextStyle(color: primaryPro,fontWeight: FontWeight.w700,fontSize: 24,letterSpacing: 1)),
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed:() async {
                  setState(() {next = true;});

                  final auth = Provider.of<AuthProvider>(context,listen: false);
                  final provider = Provider.of<CategoriesProvider>(context,listen: false);

                  if(FirebaseAuth.instance.currentUser?.phoneNumber != null){
                    salonPhoneController.text = FirebaseAuth.instance.currentUser!.phoneNumber!;
                  }

                  if(salonNameController.text.isNotEmpty && salonDescController.text.isNotEmpty && salonPhoneController.text.isNotEmpty && selectGender != '' && auth.laWilaya.text.isNotEmpty && auth.laCommune.text.isNotEmpty){

                    auth.fillSalon(salonNameController.text, salonDescController.text, selectGender,salonPhoneController.text);

                    await auth.createSalon();

                    await provider.getCategories()
                    .then((value) async => await provider.getServices()
                      .then((v) => Navigator.push(context, MaterialPageRoute(builder: (context) => ChooseCategories()),))
                      .catchError((err){
                        setState(() {next = false;});
                        final snackBar = SnackBar(
                          elevation: 10,
                          backgroundColor: Colors.red.shade700,
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            err.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      })
                    ).catchError((e){
                      setState(() {next = false;});
                      final snackBar = SnackBar(
                        elevation: 10,
                        backgroundColor: Colors.red.shade700,
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          e.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    });

                  }
                  else{
                    final snackBar = SnackBar(
                      elevation: 10,
                      duration: const Duration(seconds: 3),
                      backgroundColor: Colors.red.shade700,
                      behavior: SnackBarBehavior.floating,
                      content: const Text(
                        "Remplissez les informations de votre salon",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
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
              const SizedBox(width: 10,)
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

