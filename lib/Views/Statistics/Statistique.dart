// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Provider/AuthProvider.dart';
import '../../Provider/StatisticsProvider.dart';
import '../../Theme/colors.dart';


class Statistics extends StatefulWidget {
  const Statistics({Key? key}) : super(key: key);

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {

  bool done = false;
  bool error = false;

  Future<void> getStatistics() async {
    final provider =  Provider.of<StatisticsProvider>(context,listen: false);
    await provider.getStatistics(context).then((value){
      Timer(const Duration(seconds: 1), () {setState(() {done = true;});});
    }).catchError((onError){setState(() {done = true;error = true;});});
  }

  @override
  void initState() {
    getStatistics();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final prv = Provider.of<AuthProvider>(context,listen: false);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Statistiques",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,)),
          backgroundColor: primary,
          centerTitle: true,
          leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.arrow_back_rounded,color: Colors.white,)),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 4,
            //labelStyle: TextStyle(fontWeight: FontWeight.w700,fontFamily: "Rubik",fontSize: 16),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white38,
            tabs: [
              Tab(text: "TOTAL",),
              Tab(text: "Ce mois-ci",),
            ],
          ),
        ),
        body: SizedBox(
          height: size.height,
          width: size.width,
          child: !done ? const Center(child: CircularProgressIndicator(color: primary, strokeWidth: 3,)) :
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10,),
                SizedBox(
                  height: size.height * 0.45,
                  width: size.width,
                  child: const TabBarView(
                    children: [
                      StatisticsBodyYear(),
                      StatisticsBody(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18,top: 10,right: 28), child: Row(
                  children: const [
                    Text("Top services", style: TextStyle(color: primaryPro, fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: 1), maxLines: 3,),
                    Spacer(),
                    Text("№", style: TextStyle(color: primaryPro, fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: 1), maxLines: 3,),
                  ],
                ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(.1),
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                  ),
                  child: prv.mySalon.pack == 3 || prv.mySalon.pack == 1 ?
                  Consumer<StatisticsProvider>(
                    builder: (context, stat, child) {
                      if(stat.done != true) {
                        return const SizedBox();
                      }
                      return Column(
                          children: stat.statistic.services.keys.map((e) => SizedBox(
                            height: 40,
                            child: ListTile(
                              title: Text(e),
                              trailing: Text(stat.statistic.services[e].toString()),
                            ),
                          )).toList()
                      );
                    }
                  ):
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Lottie.asset("assets/animation/upgrade.json",reverse: true),
                      const Text("Mettez à niveau votre abonnement maintenant !",textAlign: TextAlign.center,style: TextStyle(fontSize: 22,fontWeight: FontWeight.w700,letterSpacing: 0.8),),
                      const SizedBox(height: 20,),
                      TextButton(
                        onPressed:()async {
                          final Uri tlpn = Uri(scheme: 'tel', path: "05 60 32 59 74",);
                          await launchUrl(tlpn);
                        },
                        child: const Text("05 60 32 59 74",style: TextStyle(fontSize: 22,fontWeight: FontWeight.w700,letterSpacing: 0.8)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




class StatisticsBody extends StatelessWidget {
  const StatisticsBody({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<StatisticsProvider>(
        builder: (context, stat, child) {
          if(stat.done != true) {
            return const Center(child: CircularProgressIndicator(color: primary, strokeWidth: 3,));
          }
          return GridView.builder(
            controller: ScrollController(keepScrollOffset: false),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: size.width * 0.06,
              mainAxisSpacing: size.width * 0.03,
              childAspectRatio: 1.5,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: 6,
            itemBuilder: (BuildContext context, int index) {
              switch (index) {
                case 0:
                  return StatisticsCard(
                    icon: CupertinoIcons.calendar_today,
                    text: "Rendez-vous",
                    color: clr3,
                    onTap: () {},
                    number: stat.statistic.rdv,
                  );
                case 1:
                  return StatisticsCard(
                    icon: CupertinoIcons.checkmark_circle,
                    text: "Rendez-vous acceptés",
                    color: Colors.teal.shade900,
                    onTap: () {},
                    number: stat.statistic.rdvDone,
                  );
                case 2:
                  return StatisticsCard(
                    icon: CupertinoIcons.eye,
                    text: "Vues",
                    color: Colors.indigoAccent,
                    onTap: () {},
                    number: stat.statistic.vue,
                  );
                case 3:
                  return StatisticsCard(
                    icon: CupertinoIcons.clear,
                    text: "Rendez-vous annulés",
                    color: pink,
                    onTap: () {},
                    number: stat.statistic.rdv! - stat.statistic.rdvDone!,
                  );
                case 4:
                  return StatisticsCard(
                    icon: CupertinoIcons.phone,
                    text: "appels",
                    color: Colors.green.shade900,
                    onTap: () {},
                    number: stat.statistic.tlpn,
                  );
                case 5:
                  return StatisticsCard(
                    icon: Icons.location_on_outlined,
                    text: "Maps",
                    color: Colors.yellow.shade900,
                    onTap: () {},
                    number: stat.statistic.maps,
                  );
                default:
                  return const SizedBox();
              }
            },
          );

        }
    );
  }
}

class StatisticsBodyYear extends StatelessWidget {
  const StatisticsBodyYear({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<StatisticsProvider>(
      builder: (context, stat, child) {
        if(stat.done != true) {
          return const Center(child: CircularProgressIndicator(color: primary, strokeWidth: 3,));
        }
        return StreamBuilder<Object>(
          stream: null,
          builder: (context, snapshot) {
            return GridView.builder(
              controller: ScrollController(keepScrollOffset: false),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: size.width * 0.06,
                mainAxisSpacing: size.width * 0.03,
                childAspectRatio: 1.5,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: 7,
              itemBuilder: (BuildContext context, int index) {
                switch (index) {
                  case 0:
                    return StatisticsCard(
                      icon: CupertinoIcons.calendar_today,
                      text: "Rendez-vous",
                      color: clr3,
                      onTap: () {},
                      number: stat.statistic.rdvTotal,
                    );
                  case 1:
                    return StatisticsCard(
                      icon: CupertinoIcons.checkmark_circle,
                      text: "Rendez-vous acceptés",
                      color: Colors.teal.shade900,
                      onTap: () {},
                      number: stat.statistic.rdvDoneTotal,
                    );
                  case 2:
                    return StatisticsCard(
                      icon: CupertinoIcons.eye,
                      text: "Vues",
                      color: Colors.indigoAccent,
                      onTap: () {},
                      number: stat.statistic.vueTotal,
                    );
                  case 3:
                    return StatisticsCard(
                      icon: CupertinoIcons.clear,
                      text: "Rendez-vous annulés",
                      color: pink,
                      onTap: () {},
                      number: stat.statistic.rdvTotal! - stat.statistic.rdvDoneTotal!,
                    );
                  case 4:
                    return StatisticsCard(
                      icon: CupertinoIcons.phone,
                      text: "appels",
                      color: Colors.green.shade900,
                      onTap: () {},
                      number: stat.statistic.tlpnTotal,
                    );
                  case 5:
                    return StatisticsCard(
                      icon: Icons.location_on_outlined,
                      text: "Maps",
                      color: Colors.yellow.shade900,
                      onTap: () {},
                      number: stat.statistic.mapsTotal,
                    );
                  case 6:
                    return StatisticsCard(
                      icon: CupertinoIcons.bookmark_fill,
                      text: "Favorites",
                      color: Colors.black45,
                      onTap: () {},
                      number: stat.statistic.favorites,
                    );
                  default:
                    return const SizedBox();
                }
              },
            );
          }
        );
      }
    );
  }
}



class StatisticsCard extends StatelessWidget {
  StatisticsCard({Key? key,required this.icon, required this.text, required this.color, required this.onTap, required this.number}) : super(key: key);
  IconData icon;
  String text;
  int? number;
  Color color;
  void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Material(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      color: color.withOpacity(.1),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        onTap: onTap,
        splashColor: color.withOpacity(.5),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: size.width * 0.3,height: 40 ,child: Text(text,style:TextStyle(color: color,fontWeight: FontWeight.w600,fontSize: 15),)),
                  Icon(icon,color: color,),
                ],
              ),
              Expanded(child: Center(child: Text(number.toString(),textAlign: TextAlign.center,style: const TextStyle(fontSize: 20,fontWeight: FontWeight.w600),)),),
              const SizedBox(height: 5,),
            ],
          ),
        ),
      ),
    );
  }
}
