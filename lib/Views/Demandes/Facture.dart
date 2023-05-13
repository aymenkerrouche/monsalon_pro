import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:monsalon_pro/Widgets/SnaKeBar.dart';
import 'package:monsalon_pro/models/RendezVous.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Provider/rdvProvider.dart';
import '../../Theme/colors.dart';
import '../../utils/const.dart';
import '../Home/Home.dart';

class FactureScreen extends StatelessWidget {
  const FactureScreen({Key? key, required this.rdv,required this.color, this.createRDV = false}) : super(key: key);
  final RendezVous rdv;
  final Color color;
  final bool createRDV;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Rendez-vous",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 24)),
        backgroundColor: color,
        elevation: 5,
        centerTitle: true,
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.arrow_back_rounded,color: Colors.white,)),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 15,),

              // CLIENT
              SizedBox(
                height: 20,
                child: Row(
                  children: const [
                    Icon(CupertinoIcons.person,color: Colors.grey,size: 20,),
                    SizedBox(width: 10,),
                    Text("Client (e)", style: TextStyle(fontSize: 16,color: Colors.grey,fontWeight: FontWeight.w600,),),
                  ],
                ),
              ),
              Container(
                width: size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(14)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 1), // changes position of shadow
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(horizontal:12,vertical: 2),
                child:ListTile(
                  minVerticalPadding: 15,
                  title: Text("${rdv.user}".toTitleCase(), style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w700,),maxLines: 2,),
                  subtitle:  Text(rdv.userPhone!.isEmpty ? "05 -- -- -- --" : "${rdv.userPhone}", style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w600,),maxLines: 2,),
                  trailing: IconButton(
                    onPressed:() async {
                      if(rdv.userPhone!.isEmpty){
                        final snackBar = snaKeBar("le client n'a pas de numéro de téléphone");
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                      else{
                        final Uri tlpn = Uri(scheme: 'tel', path: rdv.userPhone,);
                        await launchUrl(tlpn);
                      }
                    },
                    icon: const Icon(CupertinoIcons.phone,color: Colors.white,size: 26,),
                    style: IconButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 20
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              const SizedBox(height: 15,),

              // RDV
              SizedBox(
                height: 20,
                child: Row(
                  children:  const [
                    Icon(CupertinoIcons.calendar_today,color: Colors.grey,size: 20,),
                    SizedBox(width: 10,),
                    Text("Rendez-vous", style: TextStyle(fontSize: 16,color: Colors.grey,fontWeight: FontWeight.w600,),),
                  ],
                ),
              ),
              Container(
                width: size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 1), // changes position of shadow
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(horizontal:12,vertical: 12),
                child: Text("${rdv.date} à ${rdv.hour}h".toTitleCase(), style: const TextStyle(fontSize: 17,fontWeight: FontWeight.w700,),maxLines: 2,),
              ),


              // Expert
              if(rdv.team == true)Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15,),
                  SizedBox(
                    height: 20,
                    child: Row(
                      children:  const [
                        Icon(Icons.chair_outlined,color: Colors.grey,size: 20,),
                        SizedBox(width: 10,),
                        Text("Expert", style: TextStyle(fontSize: 16,color: Colors.grey,fontWeight: FontWeight.w600,),),
                      ],
                    ),
                  ),
                  Container(
                    width: size.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(horizontal:22,vertical: 12),
                    child: Text("${rdv.teamInfo!.name}".toTitleCase(), style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w700,color: Colors.black),maxLines: 2,),
                  ),
                ],
              ),
              const SizedBox(height: 15,),

              // SERVICES
              SizedBox(
                height: 20,
                child: Row(
                  children: const [
                    Icon(CupertinoIcons.scissors,color: Colors.grey,size: 20,),
                    SizedBox(width: 10,),
                    Text("Prestations", style: TextStyle(fontSize: 16,color: Colors.grey,fontWeight: FontWeight.w600,),),
                  ],
                ),
              ),
              Container(
                width: size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(14)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 1), // changes position of shadow
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(horizontal:12,vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: rdv.services.map((e) =>
                    SizedBox(
                      width: size.width,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              alignment: Alignment.topLeft,
                              constraints: BoxConstraints(maxWidth: size.width * 0.55),
                              child: Text("${e.service}", style: const TextStyle(fontSize: 15,fontWeight: FontWeight.w700,),maxLines: 2,)),
                          Flexible(
                            child: Text( e.prixFin != 0 ? "${e.prix} - ${e.prixFin} DA" : "${e.prix} DA", style: const TextStyle(fontSize: 15,fontWeight: FontWeight.w600,),maxLines: 1,),
                          ),
                        ],
                      ),
                    ),
                  ).toList()
                ),
              ),

              const Divider(height: 40,),

              // PRIX
              Text("PRIX", style: TextStyle(fontSize: 16,color: color,fontWeight: FontWeight.bold),),

              Container(
                width: size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 1), // changes position of shadow
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(horizontal:12,vertical: 12),
                child: Column(
                  children: [
                    // PRIX
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      height: 20,
                      child: Row(
                        children: [
                          const Text("Montant", style: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w600),),
                          const Spacer(),
                          Text(rdv.prixFin == rdv.prix ? "${rdv.prix} DA" : "${rdv.prix} - ${rdv.prixFin} DA", style: const TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w600),),
                        ],
                      ),
                    ),

                    // REMISE
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      height: 20,
                      child: Row(
                        children: [
                          Text("Remise", style: TextStyle(fontSize: 16,color: Colors.red.shade700,fontWeight: FontWeight.w600),),
                          const Spacer(),
                          Text("- ${rdv.remise} DA", style: TextStyle(fontSize: 16,color: Colors.red.shade700,fontWeight: FontWeight.w600),),
                        ],
                      ),
                    ),

                    // TOTAL
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      height: 20,
                      child: Row(
                        children: [
                          Text("Total", style: TextStyle(fontSize: 16,color: Colors.teal.shade600,fontWeight: FontWeight.w700),),
                          const Spacer(),
                          Text(rdv.prixFin == rdv.prix ? "${formatPrice(rdv.prix!-rdv.remise!)} DA" : "${formatPrice(rdv.prix!-rdv.remise!)} - ${formatPrice(rdv.prixFin!-rdv.remise!)} DA",
                            style: TextStyle(fontSize: 16,color: Colors.teal.shade600,fontWeight: FontWeight.w700),),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: kToolbarHeight,),

              if(rdv.etat == 1 || rdv.etat == 1)ElevatedButton(
                onPressed: () async {
                  if(createRDV == true){
                    await Provider.of<RdvProvider>(context,listen: false).createRDV(context,rdv.salonID!).then((value){
                      if(value == true){
                        Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (BuildContext context) => const HomePage()), (Route<dynamic> route) => false);
                      }
                    });
                  }
                  else{
                    if(rdv.etat == 1 && DateTime.now().isBefore(rdv.date2!.toDate())){
                      const snackBar = SnackBar(
                        elevation: 10,
                        behavior: SnackBarBehavior.floating,
                        content: Text("vous ne pouvez pas le terminer avant la date du rendez-vous", style: TextStyle(color: Colors.white),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                    else if(rdv.etat == 1){
                      Timer(const Duration(milliseconds: 200),() async {
                        await Provider.of<RdvProvider>(context,listen: false).terminerRDV(rdv.id!,rdv.userID!,context)
                            .then((value) => Navigator.of(context).pop());
                      });
                    }
                    else{
                      Timer(const Duration(milliseconds: 200),() async {
                        await Provider.of<RdvProvider>(context,listen: false).acceptDemande(rdv.id!,rdv.userID!,rdv.prix!-rdv.remise!,rdv.prixFin!-rdv.remise!,context,rdv.date2!,rdv.salonID!)
                            .then((value) => Navigator.of(context).pop());
                      });
                    }
                  }

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  fixedSize: const Size(double.maxFinite, 50),
                  elevation: 4,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:  [
                    Text( rdv.etat == 0 ? 'Accepter' : "Terminer", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20,color: Colors.white),),
                    const SizedBox(width: 15,),
                    const Icon(CupertinoIcons.checkmark_alt,color: Colors.white)
                  ],
                ),

              ),

              const SizedBox(height: 25,),

              if(createRDV == false && (rdv.etat == 1 || rdv.etat == 0) ) OutlinedButton(
                onPressed: (){
                  Timer(const Duration(milliseconds: 200),() async {
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext cxt) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          title:  Text(rdv.etat == 0 ? "Refuser" : "Annuler",style: const TextStyle(fontWeight: FontWeight.w700),),
                          content: Text( rdv.etat == 0 ? "Êtes-vous sûr de vouloir refuser la demande ?" : "Êtes-vous sûr de vouloir annuler le rdv ?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () async {
                                final provider = Provider.of<RdvProvider>(context,listen: false);
                                if(rdv.etat == 0){
                                  await provider.deleteDemande(rdv.salonID!,rdv.id!,rdv.userID!).then((value) => Navigator.of(cxt).pop()).then((v) => Navigator.of(context).pop());
                                }
                                else{
                                  await provider.deleteRDV(rdv.id!, rdv.userID!,context, rdv.date2!, rdv.prix!, rdv.prixFin!,rdv.salonID!).then((value) => Navigator.of(cxt).pop()).then((v) => Navigator.of(context).pop());
                                }
                              },
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red.shade700,
                                  side: BorderSide(color: Colors.red.shade700),
                                  padding: const EdgeInsets.symmetric(horizontal: 20)
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children:[
                                  Text(rdv.etat == 0 ? "Refuser" : "Annuler"),
                                  const SizedBox(width: 5,),
                                  SvgPicture.asset("assets/icons/Trash.svg",color: Colors.red.shade700,),
                                ]
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(cxt).pop();
                                //await FirebaseFirestore.instance.collection("services").where("")
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red.shade700,
                                //side: BorderSide(color: Colors.red.shade700),

                              ),
                              child: const Text('Non'),
                            ),
                          ],
                        );
                      },
                    );

                  });
                },
                style: OutlinedButton.styleFrom(
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                  side: BorderSide(color: Colors.red.shade800, width: 1),
                  foregroundColor: Colors.red.shade800,
                  fixedSize: const Size(double.maxFinite, 48),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(rdv.etat == 0 ? "Refuser" : "Annuler" , style: TextStyle(color: Colors.red.shade800,fontWeight: FontWeight.w600,fontSize: 20),),
                    const SizedBox(width: 15,),
                    Icon(CupertinoIcons.clear_thick,color: Colors.red.shade800)
                  ],
                ),
              ),

              const SizedBox(height: kToolbarHeight,),

            ],
          ),
        ),
      ),
    );
  }
}