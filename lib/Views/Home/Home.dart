
// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:badges/badges.dart' as badges;
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/jiffy.dart';
import 'package:lottie/lottie.dart';
import 'package:monsalon_pro/Theme/colors.dart';
import 'package:monsalon_pro/Views/Profil/Profile.dart';
import 'package:monsalon_pro/Views/Statistics/Statistique.dart';
import 'package:monsalon_pro/Views/Update/Informations.dart';
import 'package:monsalon_pro/Views/account/UpdateProfileScreen.dart';
import 'package:monsalon_pro/utils/const.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Provider/AuthProvider.dart';
import '../../Provider/UserProvider.dart';
import '../../Widgets/SnaKeBar.dart';
import '../../main.dart';
import '../Auth/authOTP.dart';
import '../Demandes/Demandes.dart';
import '../Money/Money.dart';
import '../RDV/ListRDV.dart';
import '../RDV/NewRDV.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    getInfo();
    super.initState();
  }

  getInfo() async {
    if(prefs?.getBool("expertMode") == true){
      Provider.of<UserProvider>(context,listen: false).getExpert(context).then((value) => Provider.of<UserProvider>(context,listen: false).getTeamInfo(context));
    }
    else{
      await Provider.of<AuthProvider>(context,listen: false).getInfos(context,FirebaseAuth.instance.currentUser?.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text("Dashboard",style: TextStyle(color: Colors.white),),
        backgroundColor: primary,
        actions: [
          if(prefs?.getBool("expertMode") == true)IconButton(
            onPressed:()=>Timer(const Duration(milliseconds: 150),() async {
              final providerAuth = Provider.of<AuthProvider>(context, listen: false);
              switch(FirebaseAuth.instance.currentUser?.providerData.first.providerId) {
                case 'google.com': {
                  await providerAuth.googleLogOut().then((value) => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const AuthOTP()), (route) => false));
                }
                break;
                default: {
                  await providerAuth.logOut().then((value) => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const AuthOTP()), (route) => false));
                }
                break;
              }
            }),
            icon: const Icon(Icons.logout_rounded,color: Colors.white,size: 26,),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white12,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
            ),
          ),
          if(prefs?.getBool("expertMode") != true)IconButton(
            onPressed:()=>Timer(const Duration(milliseconds: 150),()=>Navigator.push(context, CupertinoPageRoute(builder: (context) => const UpdateInformation()),)),
            icon: const Icon(CupertinoIcons.person,color: Colors.white,size: 26,),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white12,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
            ),
          ),
          const SizedBox(width: 8,),
        ],
      ),
      body: prefs!.getBool("expertMode") == false ? const HomeBody(): const HomeBodyExpert(),
    );
  }
}


// SALON
class HomeBody extends StatelessWidget {
  const HomeBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20,left: 5,right: 5),
      child: Column(
        children: [
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: primary,
            child: InkWell(
              onTap: ()=> showUpgrade(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal:8.0,vertical: 6),
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Consumer<AuthProvider>(
                        builder: (context, provider, child){
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(width: 10,),
                                  const Text("Abonnement : ",style: TextStyle(color: Colors.white),),
                                  Text( provider.mySalon.pack == 0 ? "Mode d'essai" : provider.mySalon.pack == 1 ? "Basic" : provider.mySalon.pack == 2 ? "Silver" : provider.mySalon.pack ==3 ? "Gold" : "Non défini, contactez-nous", style: const TextStyle(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.white),),
                                ],
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 10,),
                                  const Text("Jusqu'au : ",style: TextStyle(color: Colors.white),),
                                  if(provider.mySalon.createdAt != null) Text(" ${weekdayName[Jiffy(provider.mySalon.createdAt!.toDate()).day]} ${DateFormat("dd-MM-yyyy").format(Jiffy(provider.mySalon.createdAt!.toDate()).add(months: 6).dateTime)}".toTitleCase(),style: const TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      Lottie.asset("assets/animation/upgrade.json",height: 60,reverse: true,repeat: true)
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: Consumer<AuthProvider>(builder: (context, provider, child){
              return GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  children: [
                    DashboardCard(
                      icon:CupertinoIcons.chart_pie,
                      text:"Statistiques",
                      color: clr3,
                      photo: "assets/icons/chart.png",
                      onTap: () {
                        if(provider.mySalon.pack == 3 || provider.mySalon.pack == 0 || provider.mySalon.pack == 2){
                          Timer(const Duration(milliseconds: 150), () => Navigator.push(context, CupertinoPageRoute(builder: (context) => const Statistics()),));
                        }
                        else{
                          showUpgrade(context);
                        }
                      },
                    ),
                    DashboardCard(icon:CupertinoIcons.creditcard, text:"Revenus",color: Colors.cyan,photo: "assets/icons/money.png",onTap: () {
                      if(provider.mySalon.pack == 3 || provider.mySalon.pack == 0){
                        Timer(const Duration(milliseconds: 150), () => Navigator.push(context, CupertinoPageRoute(builder: (context) => MoneyScreen(color: Colors.cyan.shade800,)),));
                      }
                      else{
                        showUpgrade(context);
                      }

                    }),

                    DashboardCard(icon:CupertinoIcons.calendar_today, text:"Rendez-vous",color: Colors.teal.shade500 ,photo: "assets/icons/add.png",onTap: ()=>Timer(const Duration(milliseconds: 150),()=>Navigator.push(context, CupertinoPageRoute(builder: (context) => LesRendezVous(color: Colors.teal.shade500,)),)),),
                    DashboardCard(icon:CupertinoIcons.list_bullet, text:"Demandes",color: Colors.pink.shade700 ,photo: "assets/icons/inbox.png",onTap: ()=>Timer(const Duration(milliseconds: 150),()=>Navigator.push(context, CupertinoPageRoute(builder: (context) =>  LesDemandes(color: Colors.pink.shade700,)),)),),

                    DashboardCard(icon:CupertinoIcons.rectangle_stack_person_crop, text:"Profil",color: Colors.blue.shade800,photo: "assets/icons/user.png",onTap:  ()=>Timer(const Duration(milliseconds: 150),()=>Navigator.push(context, CupertinoPageRoute(builder: (context) =>  const Profile(),),)),),
                    DashboardCard(icon:CupertinoIcons.add, text:"Nouveau",color: Colors.lightGreen.shade900,photo: "assets/icons/nv.png",onTap:(){
                      {
                        if(provider.mySalon.pack == 3 || provider.mySalon.pack == 0 || provider.mySalon.pack == 2){
                          Timer(const Duration(milliseconds: 150),()=>Navigator.push(context, CupertinoPageRoute(builder: (context) => const CreateRdv()),));
                        }
                        else{
                          showUpgrade(context);
                        }
                      }
                    }),

                  ]
              );
            },
            ),
          ),
        ],
      ),
    );
  }
}

showUpgrade(context){
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (BuildContext cxt) {
      return Dialog(
        backgroundColor: background,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset("assets/animation/upgrade.json",reverse: true),
                const Text("Mettez à niveau votre abonnement maintenant !",textAlign: TextAlign.center,style: TextStyle(fontSize: 22,fontWeight: FontWeight.w700,letterSpacing: 0.8),),
                const SizedBox(height: 30,),
                TextButton(
                  onPressed:()async {
                    final Uri tlpn = Uri(scheme: 'tel', path: "05 60 32 59 74",);
                    await launchUrl(tlpn);
                  },
                  child: const Text("05 60 32 59 74",style: TextStyle(fontSize: 22,fontWeight: FontWeight.w700,letterSpacing: 0.8)),
                ),
                const SizedBox(height: 20,),
              ],
            )
        ),
      );
    },
  );
}

class DashboardCard extends StatelessWidget {
  DashboardCard({Key? key,required this.icon, required this.text, required this.color, required this.photo, required this.onTap}) : super(key: key);
  IconData icon;
  String text;
  Color color;
  String photo;
  void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          Expanded(
            child: Material(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              color: color.withOpacity(0.1),
              child: InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                onTap: onTap,
                splashColor: color.withOpacity(.5),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(icon,size: 30,color: color,),
                          const Spacer(),
                          if(text == "Les demandes")
                            StreamBuilder<QuerySnapshot?>(
                              stream: FirebaseFirestore.instance.collection("rdv").where("salonID",isEqualTo: FirebaseAuth.instance.currentUser?.uid).where("etat",isEqualTo: 0).where("date2", isGreaterThanOrEqualTo: DateTime.now()).orderBy("date2").snapshots(),
                              builder: (context, snapshot) {
                                if(snapshot.hasData) {
                                  if(snapshot.data!.docs.isNotEmpty) {
                                    return badges.Badge(badgeStyle: BadgeStyle(badgeColor: color),badgeContent: Text(snapshot.data!.docs.length.toString(),style: const TextStyle(color: Colors.white),));
                                  }
                                }
                                return const SizedBox();
                              }
                          ),
                          if(text == "Rendez-vous")
                            StreamBuilder<QuerySnapshot?>(
                                stream: FirebaseFirestore.instance.collection("rdv").where("salonID",isEqualTo: FirebaseAuth.instance.currentUser?.uid).where("etat",isEqualTo: 1).where("date2", isGreaterThanOrEqualTo: DateTime.now()).orderBy("date2").snapshots(),
                                builder: (context, snapshot) {
                                  if(snapshot.hasData) {
                                    if(snapshot.data!.docs.isNotEmpty) {
                                      return badges.Badge(badgeStyle: BadgeStyle(badgeColor: color),badgeContent: Text(snapshot.data!.docs.length.toString(),style: const TextStyle(color: Colors.white),));
                                    }
                                  }
                                  return const SizedBox();
                                }
                            ),
                            if(Provider.of<AuthProvider>(context,listen: false).mySalon.pack == 0 && text == "Nouveau RDV")
                              badges.Badge(badgeStyle: BadgeStyle(badgeColor: color))],
                      ),
                      const SizedBox(height: 5,),
                      Expanded(child: Container(margin: const EdgeInsets.only(left: 5),child: Image.asset(photo))),
                      const SizedBox(height: 10,),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10,),
          Text(text,textAlign: TextAlign.center,style: const TextStyle(fontSize: 20,fontWeight: FontWeight.w600),),
        ],
      ),
    );
  }
}




// EXPERT
class HomeBodyExpert extends StatelessWidget {
  const HomeBodyExpert({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Consumer<UserProvider>(builder: (context, provider, child){
        return Column(
          children: [
            const SizedBox(height: 10,),
            Row(
              children: [
                Icon(Icons.badge_outlined,color: Colors.cyan.shade700,),
                const SizedBox(width: 10,),
                const Text("ID",style: TextStyle(fontSize: 16,color: Colors.black54),),
              ],
            ),
            const SizedBox(height: 10,),
            ListTile(
              tileColor: Colors.cyan.shade100.withOpacity(0.5),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              title: Text("${FirebaseAuth.instance.currentUser?.uid}",style: const TextStyle(fontSize: 14,letterSpacing: .6,fontWeight: FontWeight.w600),),
              subtitle: const Text("Copiez votre ID et envoyez-le à votre manager",style: TextStyle(fontSize: 13,color: Colors.black54),),
              trailing: Icon(CupertinoIcons.qrcode_viewfinder,color: Colors.cyan.shade700,size: 30,),
              onTap: (){
                Clipboard.setData(ClipboardData(text: FirebaseAuth.instance.currentUser?.uid));
                final snackBar = snaKeBarIcon("Votre ID a bien été copié",Icons.copy);
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                showDialog<void>(
                  context: context,
                  barrierColor: Colors.black.withOpacity(.8),
                  builder: (BuildContext cxt) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      elevation: 50,
                      content: Container(
                        height: 240,
                        width: 240,
                        padding: const EdgeInsets.all(8),
                        child: PrettyQr(
                          image: const AssetImage('assets/images/logo.png'),
                          typeNumber: 3,
                          data: FirebaseAuth.instance.currentUser!.uid,
                          errorCorrectLevel: QrErrorCorrectLevel.M,
                          roundEdges: true,
                        ),
                      ),
                    );
                  },
                );
              },
            ),


            const SizedBox(height: 15,),
            Row(
              children:  [
                Icon(Icons.storefront,color: provider.expert.team?.salonID != null ? primary :  Colors.pinkAccent,),
                const SizedBox(width: 10,),
                const Text("Salon ID",style: TextStyle(fontSize: 16,color: Colors.black54),),
              ],
            ),
            const SizedBox(height: 10,),
            ListTile(
              tileColor: provider.expert.team?.salonID != null ? primaryLite : Colors.pinkAccent.shade100.withOpacity(.2),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              title: provider.expert.team?.salonID != null ?
              Text("${provider.expert.team?.salonID}"):
              const Text("Aucun salon"),
              trailing: provider.expert.team?.salonID != null ?
              const Icon(CupertinoIcons.checkmark_seal,color: primary,) :
              const Icon(Icons.warning_amber_rounded,color: Colors.pinkAccent,),
            ),


            const SizedBox(height: 20,),
            Expanded(
              child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  children: [

                    DashboardCardExpert(icon:CupertinoIcons.calendar_today, text:"Rendez-vous",color: Colors.teal.shade500 ,photo: "assets/icons/add.png",onTap: ()=>Timer(const Duration(milliseconds: 150),()=>Navigator.push(context, CupertinoPageRoute(builder: (context) => LesRendezVous(color: Colors.teal.shade500,)),)),),
                    DashboardCardExpert(icon:CupertinoIcons.list_bullet, text:"Demandes",color: Colors.pink.shade700 ,photo: "assets/icons/inbox.png",onTap: ()=>Timer(const Duration(milliseconds: 150),()=>Navigator.push(context, CupertinoPageRoute(builder: (context) =>  LesDemandes(color: Colors.pink.shade700,)),)),),

                    DashboardCardExpert(icon:CupertinoIcons.rectangle_stack_person_crop, text:"Profil",color: Colors.blue.shade800,photo: "assets/icons/user.png",onTap:  ()=>Timer(const Duration(milliseconds: 150),()=>Navigator.push(context, CupertinoPageRoute(builder: (context) =>  const UpdateProfileScreen(),),)),),
                    DashboardCardExpert(icon:CupertinoIcons.add, text:"Nouveau",color: Colors.lightGreen.shade900,photo: "assets/icons/nv.png",onTap:(){
                      Timer(const Duration(milliseconds: 150),()=>Navigator.push(context, CupertinoPageRoute(builder: (context) => const CreateRdv()),));
                    }),

                  ]
              ),
            ),
          ],
        );
      }),
    );
  }
}

class DashboardCardExpert extends StatelessWidget {
  DashboardCardExpert({Key? key,required this.icon, required this.text, required this.color, required this.photo, required this.onTap}) : super(key: key);
  IconData icon;
  String text;
  Color color;
  String photo;
  void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          Expanded(
            child: Material(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              color: color.withOpacity(0.1),
              child: InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                onTap: text == "Profil" ? onTap :
                Provider.of<UserProvider>(context,listen: false).expert.team?.salonID == null ? (){
                  final snackBar = snaKeBar("Dites à votre gérant de vous ajouter à la liste des experts");
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } : onTap,
                splashColor: color.withOpacity(.5),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(icon,size: 30,color: color,),
                          const Spacer(),

                          if(text == "Les demandes") Consumer<UserProvider>(builder: (context, expert, widget){
                            if(expert.expert.haveTeam){
                              return StreamBuilder<QuerySnapshot?>(
                                stream: FirebaseFirestore.instance.collection("rdv").where("salonID",isEqualTo: expert.expert.team?.salonID).where("etat",isEqualTo: 0).where("date2", isGreaterThanOrEqualTo: DateTime.now()).orderBy("date2").snapshots(),
                                builder: (context, snapshot) {
                                  if(snapshot.hasData) {
                                    if(snapshot.data!.docs.isNotEmpty) {
                                      return badges.Badge(badgeStyle: BadgeStyle(badgeColor: color),badgeContent: Text(snapshot.data!.docs.length.toString(),style: const TextStyle(color: Colors.white),));
                                    }
                                  }
                                  return const SizedBox();
                                }
                              );
                            }
                            return const SizedBox();
                          }),

                          if(text == "Rendez-vous") Consumer<UserProvider>(builder: (context, expert, widget){
                            if(expert.expert.haveTeam){
                              return StreamBuilder<QuerySnapshot?>(
                                  stream: FirebaseFirestore.instance.collection("rdv").where("salonID",isEqualTo: expert.expert.team?.salonID).where("etat",isEqualTo: 1).where("date2", isGreaterThanOrEqualTo: DateTime.now().subtract(const Duration(hours: 12))).orderBy("date2").snapshots(),
                                  builder: (context, snapshot) {
                                    if(snapshot.hasData) {
                                      if(snapshot.data!.docs.isNotEmpty) {
                                        return badges.Badge(badgeStyle: BadgeStyle(badgeColor: color),badgeContent: Text(snapshot.data!.docs.length.toString(),style: const TextStyle(color: Colors.white),));
                                      }
                                    }
                                    return const SizedBox();
                                  }
                              );
                            }
                            return const SizedBox();
                          }),
                        ],
                      ),
                      const SizedBox(height: 5,),
                      Expanded(child: Container(margin: const EdgeInsets.only(left: 5),child: Image.asset(photo))),
                      const SizedBox(height: 10,),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10,),
          Text(text,textAlign: TextAlign.center,style: const TextStyle(fontSize: 20,fontWeight: FontWeight.w600),),
        ],
      ),
    );
  }
}

