import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:monsalon_pro/Provider/AuthProvider.dart';
import 'package:monsalon_pro/Widgets/SnaKeBar.dart';
import 'package:provider/provider.dart';
import '../../Widgets/Wilaya.dart';
import '../../Widgets/keyboard.dart';
import '../../theme/colors.dart';
import '../../widgets/phone TextField.dart';

class UpdateInformation extends StatelessWidget {
  const UpdateInformation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(onTap: () {FocusScope.of(context).unfocus();KeyboardUtil.hideKeyboard(context);},
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Mettre à jour",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600)),
          backgroundColor: primary,
          centerTitle: true,
          leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.arrow_back_rounded,color: Colors.white,)),
        ),
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: size.height,
            width: size.width,
            child: const UpdateInformationBody()
        ),
      ),
    );
  }
}


class UpdateInformationBody extends StatefulWidget {
  const UpdateInformationBody({Key? key}) : super(key: key);

  @override
  State<UpdateInformationBody> createState() => _UpdateInformationBodyState();
}

class _UpdateInformationBodyState extends State<UpdateInformationBody> {

  TextEditingController salonNameController = TextEditingController();
  TextEditingController salonDescController = TextEditingController();
  TextEditingController salonPhoneController = TextEditingController();

  List gender=["Male","Female","Mix"];
  String selectGender = '';
  bool next = false;

  Future<void> getInfos() async {
    final provider =  Provider.of<AuthProvider>(context,listen: false);
    await provider.getInfos(context,FirebaseAuth.instance.currentUser?.uid);
    salonNameController.text = provider.mySalon.nom!;
    salonDescController.text = provider.mySalon.description!;
    salonPhoneController.text = provider.mySalon.phone!;
    setState((){selectGender = provider.mySalon.sex!;});
  }

  @override
  void initState() {
    getInfos();
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
    Size size = MediaQuery.of(context).size;
    final provider =  Provider.of<AuthProvider>(context,listen: false);
    return SingleChildScrollView(
      child: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if(auth.done == false){
            return SizedBox(height: size.height,child: const Center(child: CircularProgressIndicator(color: primary,strokeWidth: 3,),));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20,),
              const Text("Informations du salon",
                style: TextStyle(color: primaryPro,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    letterSpacing: 1), maxLines: 3,),
              const SizedBox(height: 20,),

              TextInfomation(textController: salonNameController,
                label: "Nom",
                hint: "${provider.mySalon.nom}",
                icon: Icons.business_sharp,),
              const SizedBox(height: 30,),

              if(FirebaseAuth.instance.currentUser?.phoneNumber == null)buildPhoneNumberFormField(salonPhoneController, "phone", "${provider.mySalon.phone}"),
              if(FirebaseAuth.instance.currentUser?.phoneNumber == null)const SizedBox(height: 30,),

              TextInfomation(textController: salonDescController,
                label: "Bio",
                hint: "${provider.mySalon.description}",
                icon: Icons.description_outlined,maxLine: 3,),
              const SizedBox(height: 30,),


              const Text(
                  "Wilaya",
                  style: TextStyle(color: primaryPro,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      letterSpacing: 1)),
              const SizedBox(height: 20,),
              const Wilaya(),
              const SizedBox(height: 30,),

              const Text(
                  "Sexe",
                  style: TextStyle(color: primaryPro,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      letterSpacing: 1)),
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
              ElevatedButton(
                onPressed: () async {
                  setState(() {next = true;});
                  final provider  = Provider.of<AuthProvider>(context, listen: false);

                  if (salonNameController.text.isNotEmpty && salonDescController.text.isNotEmpty && selectGender != '' && salonPhoneController.text.isNotEmpty) {
                    provider.fillSalon(salonNameController.text, salonDescController.text, selectGender, salonPhoneController.text);
                    await provider.updateSalon()
                    .then((value){
                      setState(() {next = true;});
                      final snackBar = SnackBar(
                        elevation: 10,
                        padding: const EdgeInsets.only(left: 10),
                        backgroundColor: primaryLite2,
                        behavior: SnackBarBehavior.floating,
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Mise à jour réussie",
                              style: TextStyle(color: Colors.white,fontFamily: "Rubik"),
                            ),
                            Lottie.asset("assets/animation/done2.json",height: 50,width: 50,reverse: true,repeat: true)
                          ],
                        ),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      Navigator.pop(context);})
                    .catchError((onError){
                      final snackBar = snaKeBar(onError.toString());
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    });
                  }
                  else {
                    final snackBar = snaKeBar("Remplissez les informations de votre salon",);
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                  setState(() {next = false;});
                },
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: primary,
                    elevation: 10,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)))
                ),
                child: SizedBox(
                  height: 52,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Sauvegarder", style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: 1)),
                      const SizedBox(width: 10,),
                      next ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,),) :
                      const Icon(Icons.check_rounded, size: 22,)
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20,),
            ],
          );
        }
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
                selectGender=value;
              });
            },
          ),
          Text(title)
        ],
      ),
    );
  }
}

