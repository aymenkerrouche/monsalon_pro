import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:monsalon_pro/Widgets/phone%20TextField.dart';
import 'package:provider/provider.dart';

import '../../Provider/AuthProvider.dart';
import '../../Theme/colors.dart';
import '../../Widgets/SnaKeBar.dart';
import '../../Widgets/keyboard.dart';
import '../../models/Team.dart';
import 'ScanQrExpert.dart';

class ExpertScreen extends StatefulWidget {
  const ExpertScreen({Key? key}) : super(key: key);

  @override
  State<ExpertScreen> createState() => _ExpertScreenState();
}
class _ExpertScreenState extends State<ExpertScreen> {

  @override
  void initState() {
    getExpert();
    super.initState();
  }

  Future<void> getExpert() async {
    await Provider.of<AuthProvider>(context,listen: false).getExperts(context,FirebaseAuth.instance.currentUser?.uid).then((value) =>Timer(const Duration(milliseconds: 600), (){setState(() {done = true;});
    }));
  }

  bool done = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text("Experts",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600)),
        backgroundColor: primary,
        centerTitle: true,
        elevation: 10,
        actions: [
          IconButton(
            onPressed:(){
              Navigator.push(context, CupertinoPageRoute(builder: (context) => const QRViewExample()),);
            },
            icon: const Icon(CupertinoIcons.qrcode_viewfinder,color: Colors.white,size: 30,),
          ),
        ],
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.arrow_back_rounded,color: Colors.white,)),
      ),
      body: done ? Container(
        padding: const EdgeInsets.only(top: 10, left: 10,right: 10),
        child: Consumer<AuthProvider>(
            builder: (context, auth, child) {
              if(auth.mySalon.teams.isEmpty){
                return Container(
                    height: size.height * 0.7,
                    width: size.width,
                    padding: const EdgeInsets.symmetric(horizontal: 16),child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset("assets/icons/barber.svg",width: size.width * 0.7),
                        const SizedBox(height: 30,),
                        const Text( "Ajouter un Expert", style: TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
                      ],
                    ));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8,top: 10,bottom: 10),
                    child: Text("Nombre des experts: ${auth.mySalon.teams.length}",
                      style: const TextStyle(color: primaryPro, fontWeight: FontWeight.w600, letterSpacing: 1), maxLines: 3,),
                  ),
                  Expanded(
                    child: ListView(
                      children: List.generate(auth.mySalon.teams.length, (index) => auth.mySalon.teams[index].userID!.isNotEmpty ?
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            contentPadding: const EdgeInsets.only(left: 14, right: 6),
                            title: Text("${auth.mySalon.teams[index].name}",style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w700),),
                            subtitle: Text("ID: ${auth.mySalon.teams[index].userID}"),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                            tileColor: primaryLite.withOpacity(.3),
                            trailing: CupertinoSwitch(value: auth.mySalon.teams[index].active!, activeColor: primaryLite2, onChanged: (value){auth.activeExpert(auth.mySalon.teams[index].id,value);},),
                            onTap: (){
                              showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.white,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(16),topRight: Radius.circular(16))),
                                  builder: (context) {
                                    return Container(
                                      padding: MediaQuery.of(context).viewInsets,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(16),topRight: Radius.circular(16))
                                        ),
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(horizontal: 15),
                                        child: ModifierExpert(expert: auth.mySalon.teams[index])
                                      ),
                                    );
                                  }
                              );
                            },
                          ),
                        ):
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            contentPadding: const EdgeInsets.only(left: 14, right: 6),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                            tileColor: primaryLite.withOpacity(.3),
                            title: Text("${auth.mySalon.teams[index].name}",style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w700),),
                            trailing: CupertinoSwitch(value: auth.mySalon.teams[index].active!, activeColor: primaryLite2, onChanged: (value){auth.activeExpert(auth.mySalon.teams[index].id,value);},),
                            onTap: (){
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.white,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(16),topRight: Radius.circular(16))),
                                builder: (context) {
                                  return Container(
                                    padding: MediaQuery.of(context).viewInsets,
                                    child: Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(16),topRight: Radius.circular(16))
                                        ),
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(horizontal: 15),
                                        child: ModifierExpert(expert: auth.mySalon.teams[index])
                                    ),
                                  );
                                }
                              );
                            },
                          ),
                        )
                      ),
                    ),
                  ),
                ],
              );
            }
        ),
      ):
      const Center(child: CircularProgressIndicator(color: primary,strokeWidth: 3,),),
      floatingActionButton: FloatingActionButton(
        onPressed:(){
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(16),topRight: Radius.circular(16))),
            builder: (context) {
              return Container(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(16),topRight: Radius.circular(16))
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: const AddExpert()
                ),
              );
            }
          );
        },
        backgroundColor: primaryLite2,
        child: const Icon(Icons.add_rounded,size: 35,color: Colors.white,),
      ),
    );
  }
}





class AddExpert extends StatefulWidget {
  const AddExpert({Key? key}) : super(key: key);

  @override
  State<AddExpert> createState() => _AddExpertState();
}

class _AddExpertState extends State<AddExpert> {
  TextEditingController expertID = TextEditingController();
  TextEditingController expertName = TextEditingController();
  bool create = false;
  bool accept = false;
  bool id = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.6,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
           mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 34,
                margin: const EdgeInsets.only(top: 5,bottom: 20),
                decoration:  const BoxDecoration(
                  color: primaryPro,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
              ),
              const Text( "Ajouter un Expert", style: TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
              const SizedBox(height: 20,),
              TextInfomation(textController: expertName,hint:"Aymen ...",label: "Nom de l'Expert",icon: CupertinoIcons.person_alt_circle,textType: TextInputType.text,),

              const SizedBox(height: 15,),
              !id ? TextInfomation(textController: expertID,hint:"********",label: "ID",icon: Icons.security_rounded,textType: TextInputType.text,readOnly: id,):
              const SizedBox(),
              Row(
                children: [
                  const Text("l'expert n'a pas de compte",style: TextStyle(fontSize: 12,),textAlign: TextAlign.start,),
                  Checkbox(
                    value: id,
                    onChanged: (value) {
                      setState(() {
                        id = value!;
                        if(value == true){
                          FocusScope.of(context).unfocus();
                        }
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20,),
               ListTile(
                 contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                title: const Text("Peut créer des RDVs",style: TextStyle(fontWeight: FontWeight.w600),),
                trailing: CupertinoSwitch(value: create, activeColor: primaryLite2, onChanged: (value){setState(() {create=value;});},),
              ),

              const SizedBox(height: 10,),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                title: const Text("Peut accepter des RDVs",style: TextStyle(fontWeight: FontWeight.w600),),
                trailing: CupertinoSwitch(value: accept, activeColor: primaryLite2, onChanged: (value){setState(() {accept=value;});},),
              ),

              const SizedBox(height: 20,),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: primaryLite2,
                    foregroundColor: Colors.white,
                    fixedSize: Size(size.width, 48)
                ),
                onPressed: () async {
                  KeyboardUtil.hideKeyboard(context);
                  final provider = Provider.of<AuthProvider>(context,listen: false);
                  if(expertName.text.isEmpty  && id == true ){
                    final snackBar = snaKeBar("Ajouter le nom de l'Expert");
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                  else if(expertID.text.isEmpty && id == false){
                    final snackBar = snaKeBar("Ajouter l' ID de l'Expert");
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                  else{
                    if(provider.mySalon.teams.where((element) => element.userID == expertID.text).isEmpty){
                      Team newTeam = Team.fromJson({
                        "salonID":FirebaseAuth.instance.currentUser?.uid,
                        "name": expertName.text,
                        "userID": !id ? expertID.text : '',
                        "accept": accept,
                        "create": create,
                        "active": true
                      });
                      try{
                        await Provider.of<AuthProvider>(context,listen: false).ajouterExperts(newTeam).then((value) => Navigator.pop(context));
                      }
                      catch(e){
                        final snackBar = snaKeBar(e.toString());
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    }
                    else{
                      final snackBar = snaKeBar("L'expert existe déjà");
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  }
                },
                child:
                const Text( "Ajouter",
                  style: TextStyle(fontSize: 20, color: Colors.white,fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }
}





class ModifierExpert extends StatefulWidget {
  const ModifierExpert({Key? key, required this.expert}) : super(key: key);
  final Team expert ;
  @override
  State<ModifierExpert> createState() => _ModifierExpertState();
}

class _ModifierExpertState extends State<ModifierExpert> {

  TextEditingController expertName = TextEditingController();

  @override
  void initState() {
    setState(() {expertName.text = widget.expert.name!;});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.5,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 34,
              margin: const EdgeInsets.only(top: 5,bottom: 20),
              decoration:  const BoxDecoration(
                color: primaryPro,
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
            ),
            //const Text( "Modifier l'Expert", style: TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),

            const Spacer(),
            TextInfomation(textController: expertName,hint:expertName.text,label: "Expert",icon: CupertinoIcons.person,textType: TextInputType.text,),

            const SizedBox(height: 20,),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 5),
              title: const Text("Peut créer des RDVs",style: TextStyle(fontWeight: FontWeight.w600),),
              trailing: CupertinoSwitch(value: widget.expert.create!, activeColor: primaryLite2, onChanged: (value){setState(() {widget.expert.create = value;});},),
            ),

            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 5),
              title: const Text("Peut accepter des RDVs",style: TextStyle(fontWeight: FontWeight.w600),),
              trailing: CupertinoSwitch(value: widget.expert.accept!, activeColor: primaryLite2, onChanged: (value){setState(() {widget.expert.accept=value;});},),
            ),

            const Spacer(),
            OutlinedButton(
              onPressed: () async {
                KeyboardUtil.hideKeyboard(context);
                try{
                  await Provider.of<AuthProvider>(context,listen: false).deleteExpert(widget.expert.id).then((value) => Navigator.pop(context));
                }
                catch(e){
                  final snackBar = snaKeBar(e.toString(),);
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              style: OutlinedButton.styleFrom(
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                side: BorderSide(color: Colors.red.shade800, width: 1),
                foregroundColor: Colors.red.shade800,
                fixedSize: Size(size.width, 48),
              ),
              child: Text("Supprimer" , style: TextStyle(color: Colors.red.shade800,fontWeight: FontWeight.w600,fontSize: 20),),
            ),
            const SizedBox(height: 20,),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: primaryLite2,
                  foregroundColor: Colors.white,
                  fixedSize: Size(size.width, 48)
              ),
              onPressed: () async {

                if(expertName.text.isEmpty){
                  final snackBar = snaKeBar("Ajouter le nom de l'Expert",);
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
                else{
                  setState(() {widget.expert.name = expertName.text;});
                  KeyboardUtil.hideKeyboard(context);
                  try{
                    await Provider.of<AuthProvider>(context,listen: false).updateExpert(widget.expert).then((value) => Navigator.pop(context));
                  }
                  catch(e){
                    final snackBar = snaKeBar("Ajouter le nom de l'Expert",);
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                }
              },
              child:
              const Text( "Sauvegarder",
                style: TextStyle(fontSize: 20, color: Colors.white,fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }
}