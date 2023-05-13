// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:monsalon_pro/Provider/CategoriesProvider.dart';
import 'package:monsalon_pro/Widgets/SnaKeBar.dart';
import 'package:monsalon_pro/utils/const.dart';
import 'package:provider/provider.dart';
import '../../Provider/AuthProvider.dart';
import '../../Theme/colors.dart';
import '../../Widgets/ListOfCategories.dart';
import '../../Widgets/keyboard.dart';
import '../../Widgets/phone TextField.dart';
import '../../models/Service.dart';


// SCREEN

class UpdateCategories extends StatefulWidget {
  const UpdateCategories({Key? key}) : super(key: key);

  @override
  State<UpdateCategories> createState() => _UpdateCategoriesState();
}
class _UpdateCategoriesState extends State<UpdateCategories> {
  @override
  void initState() {
    getServices();
    super.initState();
  }
  Future<void> getServices() async {
    await Provider.of<AuthProvider>(context,listen: false).getSalonCategoriesAndServices(FirebaseAuth.instance.currentUser?.uid).then((value) =>Timer(const Duration(seconds: 1), (){setState(() {done = true;});
    }));
  }
  bool next = false;
  bool done = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: (){FocusScope.of(context).unfocus();KeyboardUtil.hideKeyboard(context);},
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: const Text("Services",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white)),
          centerTitle: true,
          backgroundColor: primary,
          elevation: 0,
          leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.arrow_back_rounded,color: Colors.white,)),
        ),
        body: done ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 12),
          height: size.height,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10,),

                // REMISE
                const Text("Remise actuelle",style: TextStyle(color: Colors.black45,fontWeight: FontWeight.w600),),
                const SizedBox(height: 10,),
                Card(
                  elevation: 6,
                  child: ListTile(
                    title: Consumer<AuthProvider>(
                      builder: (context, prv, child) {
                        return Text("${formatPrice(prv.mySalon.remise!)}  DA",style: const TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600),);
                      }
                    ),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                    trailing: Lottie.asset("assets/animation/remise.json",height: 35,reverse: true),
                    tileColor: primary,
                    onTap: ()async =>
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(16),topRight: Radius.circular(16))),
                        builder: (context) {
                          return Padding(
                              padding: MediaQuery.of(context).viewInsets,
                              child: Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(16),topRight: Radius.circular(16))
                                  ),
                                  width: size.width,
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child: const RemiseActuelle())
                          );
                        }
                      ),
                  ),
                ),
                const SizedBox(height: 30,),

                const Text("Modifiez vos services",style: TextStyle(color: Colors.black45,fontWeight: FontWeight.w600),),
                const SizedBox(height: 10,),
                const ListMesServices(),

                const SizedBox(height: 100,),
              ],
            ),
          ),
        ):
        const Center(child: CircularProgressIndicator(color: primary,strokeWidth: 3,),),
        floatingActionButton: FloatingActionButton(
          heroTag: "btn1",
          shape: const CircleBorder(),
          onPressed:() async {
            setState(() {next = true;});
            final provider = Provider.of<CategoriesProvider>(context,listen: false);
            try{
              await provider.getCategories().then((value) async {
                try{
                  await provider.getServices().then((value){
                    setState(() {next = false;});
                    Navigator.push(context, CupertinoPageRoute(builder: (context) => const ShowModelBottomUpdateServices()));
                  });
                }
                catch(err){
                  setState(() {next = false;});
                  final snackBar = snaKeBar(err.toString(),);
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);}
              });
            }
            catch(e){
              setState(() {next = false;});
              final snackBar = snaKeBar(e.toString(),);
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
            setState(() {next = false;});
          },
          tooltip: "Modifier vos services",
          backgroundColor: primaryLite2,
          child: next == true ? const SizedBox(height: 20,width: 20,child: CircularProgressIndicator(strokeWidth: 3,color: Colors.white,),):
          const Icon(Icons.add_rounded,size: 40,color: Colors.white,),
        )
      ),
    );
  }
}





// Ajouter Services
class ShowModelBottomUpdateServices extends StatefulWidget {
  const ShowModelBottomUpdateServices({Key? key}) : super(key: key);

  @override
  State<ShowModelBottomUpdateServices> createState() => _ShowModelBottomUpdateServicesState();
}
class _ShowModelBottomUpdateServicesState extends State<ShowModelBottomUpdateServices> {
  bool next = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const FittedBox(child: Text("Modifiez vos services",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),)),
        centerTitle: true,
        backgroundColor: primary,
        elevation: 5,
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.arrow_back_rounded,color: Colors.white,)),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal:14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10,),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(Provider.of<CategoriesProvider>(context,listen: false).categories.length, (index) => ServicesList(category: Provider.of<CategoriesProvider>(context,listen: false).categories[index],isNew: true,)),
                ),
              ),
            ),
            const SizedBox(height: 10,),
            ElevatedButton(
              onPressed:() async {
                setState(() {next = true;});
                try{
                  await Provider.of<AuthProvider>(context,listen: false).updateSalonCategoriesAndServices().then((value) async =>
                    await Provider.of<AuthProvider>(context,listen: false).getSalonCategoriesAndServices(FirebaseAuth.instance.currentUser?.uid).whenComplete((){setState(() {next = false;});
                    Navigator.pop(context);}));
                }
                catch(e){
                  setState(() {next = false;});
                  final snackBar = snaKeBar(e.toString());
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  elevation: 10,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)))
              ),
              child: SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:  [
                    const Text(" Sauvegarder", style: TextStyle(fontSize: 24,color: Colors.white,fontWeight: FontWeight.w600),),
                    const SizedBox(width: 10,),
                    next ? const SizedBox(height: 20,width: 20,child: CircularProgressIndicator(color: Colors.white,strokeWidth: 2.5,),) :
                    const Icon(Icons.check_rounded,size: 26,color: Colors.white,),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15,),
          ],
        ),
      ),
    );
  }
}






// Mes Services
class ListMesServices extends StatelessWidget {
  const ListMesServices({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<AuthProvider>(
        builder: (context, auth, child){
          if(auth.mySalon.service.isEmpty){
            return SizedBox(
              height: size.height * 0.6,
              width: size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Ajoutez vos services en cliquant sur le bouton ci-dessous",style: TextStyle(fontSize: 18),textAlign: TextAlign.center,),
                  const SizedBox(height: 30,),
                  SvgPicture.asset("assets/icons/list.svg",width: size.width * 0.7,),
                ],
              ),
            );
          }
          else{
            List<Service> services = auth.mySalon.service;
            services.sort((a, b) => a.service!.compareTo(b.service!));
            return Column(
              children: services.map((e) => MyServices(service:e)).toList(),
              //List.generate(services.length, (index) => MyServices(service:services[index],)),
            );
          }
        }
    );
  }
}


class MyServices extends StatefulWidget {
  const MyServices({Key? key, required this.service}) : super(key: key);
  final Service service;

  @override
  State<MyServices> createState() => _MyServicesState();
}
class _MyServicesState extends State<MyServices> {
  bool editing = false;
  bool prxFin = false;

  late TextEditingController prix;
  late TextEditingController prixFin;

  @override
  void initState() {
    prix = TextEditingController(text: widget.service.prix.toString());
    prixFin = TextEditingController(text: widget.service.prixFin.toString());
    if(prixFin.text.isNotEmpty && widget.service.prixFin != 0){setState(() {prxFin = true;});}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return  Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: InkWell(
        onLongPress: () async {
          showDialog<void>(
            context: context,
            builder: (BuildContext cxt) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title:  const Text("Supprimer",style: TextStyle(fontWeight: FontWeight.w700),),
                content: const Text("Êtes-vous sûr de vouloir supprimer ce service ?"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () async {
                      final provider = Provider.of<AuthProvider>(context,listen: false);
                      await provider.deleteSalonCategoriesAndServices(widget.service.id,widget.service.categoryID)
                          .whenComplete((){Navigator.pop(context);Navigator.pop(context);});
                    },
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade700),
                        padding: const EdgeInsets.symmetric(horizontal: 20)
                    ),
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children:[
                          const Text("Supprimer"),
                          const SizedBox(width: 5,),
                          SvgPicture.asset("assets/icons/Trash.svg",color: Colors.red.shade700,),
                        ]
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(cxt).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                    ),
                    child: const Text('Non'),
                  ),
                ],
              );
            },
          );
        },
        child: ExpansionTile(
          title: Text(widget.service.service!.toTitleCase(),style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w700),),
          textColor: primary,
          backgroundColor: primaryLite.withOpacity(.3),
          iconColor: primary,
          childrenPadding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 5,top: 10),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Text("Prix"),
                  const SizedBox(width: 10,),
                  SizedBox(
                    width: size.width * 0.15,
                    height: 40,
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      controller: prix,
                      readOnly: !editing,
                      cursorColor: primary,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: " xx DA",
                        hintStyle: const TextStyle(color: Colors.black45),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: primary, width: .5),
                            gapPadding: 6),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: clr3.withOpacity(.5), width: .5),
                            gapPadding: 6),
                      ),
                    ),
                  ),

                  const Spacer(),

                  const Text("jusqu'à"),
                  const SizedBox(width: 10,),
                  prxFin == false ?
                  IconButton(onPressed:(){setState(() {prxFin = true;});}, icon: const Icon(Icons.add_rounded,color: primary,size: 25,)):
                  SizedBox(
                    width: size.width * 0.15,
                    height: 40,
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      controller: prixFin,
                      cursorColor: primary,
                      readOnly: !editing,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: ".. DA",
                        hintStyle: const TextStyle(color: Colors.black45),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: primary, width: .5),
                            gapPadding: 6),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: clr3.withOpacity(.5), width: .5),
                            gapPadding: 6),
                      ),
                    ),
                  ),

                  if( prxFin == true && editing == true)IconButton(onPressed:(){setState(() {prxFin = false;});}, icon: const Icon(Icons.close_rounded,color: primary,)),

                  const Spacer(),
                  IconButton(
                      onPressed:() async {
                        if(editing == true){
                          if(prxFin == true && int.parse(prixFin.text) < int.parse(prix.text)){
                            const snackBar = SnackBar(
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                'Le deuxième prix doit être plus que le premier',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                          else{
                            setState(() {editing = false;});
                            if(prxFin == false || prixFin.text.isEmpty){prixFin.text = "0";}
                            if(prix.text.isEmpty){prix.text = "0";}
                            await Provider.of<AuthProvider>(context,listen: false).updateServicesPrices(widget.service.id!, int.parse(prix.text), int.parse(prixFin.text));
                          }
                        }
                        else{
                          setState(() {editing = true;});
                        }
                        },
                      icon: editing == false ? const Icon(Icons.edit_outlined,color: primary,):const Icon(Icons.save_as_rounded,color: Colors.green,)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}



// REMISE
class RemiseActuelle extends StatefulWidget {
  const RemiseActuelle({Key? key}) : super(key: key);

  @override
  State<RemiseActuelle> createState() => _RemiseActuelleState();
}

class _RemiseActuelleState extends State<RemiseActuelle> {
  TextEditingController remise = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final provider = Provider.of<AuthProvider>(context,listen: false);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children:[
        Container(
          height: 4,
          width: 30,
          margin: const EdgeInsets.only(top: 5,bottom: 30),
          decoration:  const BoxDecoration(
            color: primaryPro,
            borderRadius: BorderRadius.all(Radius.circular(50)),
          ),
        ),
        const Text( "Ajouter une réduction sur vos services",
          style: TextStyle(fontSize: 18, color: Colors.black),textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30,),
        TextInfomation(textController:remise,label:"Remise",hint:"${provider.mySalon.remise} DA",icon: Icons.discount_rounded,),
        Container(
          margin: const EdgeInsets.only(top: 20,bottom: 40),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: primaryLite2,
                foregroundColor: Colors.white,
                fixedSize: Size(size.width, 48)
            ),
            onPressed: () async {
              KeyboardUtil.hideKeyboard(context);
              try{
                if(remise.text == "0"){
                  await provider.deleteRemise().then((value){
                    final snackBar = snaKeBar("Remise bien supprimée",);
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    Navigator.pop(context);
                  });
                }
                else{
                  await provider.updateRemise(int.parse(remise.text)).then((value){
                    final snackBar = snaKeBar("La remise bien enregistrée",);
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    Navigator.pop(context);
                  });
                }

              }
              catch(e){
                Navigator.pop(context);
                final snackBar = snaKeBar(e.toString(),);
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
            child:
            const Text( "Sauvegarder",
              style: TextStyle(fontSize: 20, color: Colors.white,fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
