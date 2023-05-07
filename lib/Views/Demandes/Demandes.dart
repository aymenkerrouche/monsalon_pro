import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monsalon_pro/Provider/rdvProvider.dart';
import 'package:monsalon_pro/Views/Demandes/Facture.dart';
import 'package:provider/provider.dart';
import '../../Provider/UserProvider.dart';
import '../../Theme/colors.dart';
import '../../main.dart';
import '../../models/RendezVous.dart';
import '../../utils/const.dart';

class LesDemandes extends StatefulWidget {
  const LesDemandes({Key? key, required this.color}) : super(key: key);
  final Color color;
  @override
  State<LesDemandes> createState() => _LesDemandesState();
}

class _LesDemandesState extends State<LesDemandes> {
  bool done = false;
  bool error = false;

  Future<void> getDemandes() async {

    final provider =  Provider.of<RdvProvider>(context,listen: false);
    String salonID = '';
    if(prefs?.getBool("expertMode") == true){
      salonID = Provider.of<UserProvider>(context,listen: false).expert.team!.salonID!;
    }
    else{
      salonID = FirebaseAuth.instance.currentUser!.uid;
    }
    await provider.getDemandes(context,salonID).then((value){
      Timer(const Duration(seconds: 1), () {setState(() {done = true;});});
    }).catchError((onError){setState(() {done = true;error = true;});});
  }

  @override
  void initState() {
    getDemandes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Demandes",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 24)),
        backgroundColor: widget.color,
        centerTitle: true,
        elevation: 10,
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.arrow_back_rounded,color: Colors.white,)),
      ),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: !done ? Center(child: CircularProgressIndicator(color: widget.color, strokeWidth: 3,)) : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.only(left: 18,top: 10),
                child: Consumer<RdvProvider>(
                  builder: (context, rend, child) { return Text("Nombre de demandes: ${rend.listDemandes.length}",
                    style: const TextStyle(color: primaryPro, fontWeight: FontWeight.w700, letterSpacing: 1), maxLines: 3,);}
                ),
              ),
              ListRdv(color: widget.color,),
              const SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }
}



class ListRdv extends StatelessWidget {
  const ListRdv({Key? key, required this.color}) : super(key: key);
  final Color color;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<RdvProvider>(
        builder: (context, rend, child) {
          if(rend.done != true) {
            return SizedBox(height: size.height * 0.8,child: Center(child: CircularProgressIndicator(color: Colors.teal.shade400, strokeWidth: 3,)));
          }
          if(rend.done == true && rend.listDemandes.isEmpty) {
            return Container(padding: const EdgeInsets.symmetric(horizontal: 16),height: size.height * 0.8,child: Center(child: SvgPicture.asset("assets/icons/list.svg",height: size.height * 0.3,)));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(rend.listDemandes.length, (index) => RendezVousCard(color: color,rdv: rend.listDemandes[index],)),
          );
        }
    );
  }
}


class RendezVousCard extends StatelessWidget {
  const RendezVousCard({Key? key, required this.rdv, required this.color}) : super(key: key);
  final RendezVous rdv;
  final Color color;
  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
        child: InkWell(
          splashColor: color.withOpacity(.6),
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          onTap:  ()=>Timer(const Duration(milliseconds: 100),()=>Navigator.push(context, CupertinoPageRoute(builder: (context) =>  FactureScreen(rdv: rdv, color: color,),),)),

          child: ListTile(
            minVerticalPadding: 15,
            title: Text("${rdv.user}".toTitleCase(),style: const TextStyle(fontWeight: FontWeight.w700,fontSize: 18),),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${rdv.date}".toTitleCase(),style: const TextStyle(fontWeight: FontWeight.w700),),
                Text(rdv.prixFin! > rdv.prix! ? "${formatPrice(rdv.prix!)} - ${formatPrice(rdv.prixFin!)} DA" :"${formatPrice(rdv.prix!)} DA",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 16,color: color),),
                Text(rdv.services.length > 1 ? "${rdv.services.length} services" : "${rdv.services.length} service",style: const TextStyle(fontWeight: FontWeight.w600,),),
              ],
            ),
            isThreeLine: true,
            leading: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration:  BoxDecoration(
                color: color.withOpacity(.1),
                shape: BoxShape.circle
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("${rdv.hour}h",style: TextStyle(fontWeight: FontWeight.w700,color: color),),
                ],
              )
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment:CrossAxisAlignment.start,
              children: [
                const Text(" Etat",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 14),),
                Chip(
                  side: BorderSide.none,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  padding: EdgeInsets.zero,
                  label: Text("en attente",style: TextStyle(fontWeight: FontWeight.w700,color: color,fontSize: 14),),
                  backgroundColor: color.withOpacity(.1),),
              ],
            ),
            contentPadding: const EdgeInsets.only(left: 10,right: 15,top: 10,bottom: 10),
            visualDensity: const VisualDensity(vertical: 4),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
          ),
        ),
      ),
    );
  }
}










