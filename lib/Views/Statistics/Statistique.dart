// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Statistiques",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 24)),
          backgroundColor: primary,
          centerTitle: true,
          leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.arrow_back_rounded,color: Colors.white,)),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 4,
            labelStyle: TextStyle(fontWeight: FontWeight.w700,fontFamily: "Rubik",fontSize: 16),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white38,
            tabs: [
              Tab(text: "Ce mois-ci",),
              Tab(text: "Total",),
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
                const SizedBox(height: 20,),
                SizedBox(
                  height: size.height * 0.45,
                  width: size.width,
                  child: const TabBarView(
                    children: [
                      StatisticsBody(),
                      StatisticsBodyYear(),
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
                  child: Consumer<StatisticsProvider>(
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
          return GridView.count(
            controller: ScrollController(keepScrollOffset: false),
            crossAxisCount: 2,
            crossAxisSpacing: size.width * 0.06,
            mainAxisSpacing: size.width * 0.03,
            childAspectRatio: 1.5,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            children: [
              StatisticsCard(icon:CupertinoIcons.calendar_today, text:"Rendez-vous", color: clr3,onTap: (){},number: stat.statistic.rdv,),
              StatisticsCard(icon:CupertinoIcons.checkmark_circle, text:"Rendez-vous acceptés",color: Colors.brown.shade900,onTap: (){},number: stat.statistic.rdvDone,),

              StatisticsCard(icon:CupertinoIcons.eye, text:"Vues",color: Colors.blue.shade800, onTap: (){},number: stat.statistic.vue,),
              StatisticsCard(icon:CupertinoIcons.clear, text:"Rendez-vous annulés",color: pink, onTap: (){},number: stat.statistic.rdv! - stat.statistic.rdvDone!,),

              StatisticsCard(icon:CupertinoIcons.phone, text:"appels",color: Colors.green.shade900, onTap: (){},number: stat.statistic.tlpn,),
              StatisticsCard(icon:Icons.location_on_outlined, text:"Maps",color: Colors.yellow.shade900, onTap: (){},number: stat.statistic.maps,),
            ]
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
            return GridView.count(
                controller: ScrollController(keepScrollOffset: false),
                crossAxisCount: 2,
                crossAxisSpacing: size.width * 0.06,
                mainAxisSpacing: size.width * 0.03,
                childAspectRatio: 1.5,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                children: [
                  StatisticsCard(icon:CupertinoIcons.calendar_today, text:"Rendez-vous", color: clr3,onTap: (){}, number: stat.statistic.rdvTotal,),
                  StatisticsCard(icon:CupertinoIcons.checkmark_circle, text:"Rendez-vous acceptés",color: Colors.brown.shade900,onTap: (){},number: stat.statistic.rdvDoneTotal,),

                  StatisticsCard(icon:CupertinoIcons.eye, text:"Vues",color: Colors.blue.shade800, onTap: (){},number: stat.statistic.vueTotal,),
                  StatisticsCard(icon:CupertinoIcons.phone, text:"appels",color: Colors.green.shade900, onTap: (){},number: stat.statistic.tlpnTotal,),

                  StatisticsCard(icon:Icons.location_on_outlined, text:"Maps",color: Colors.yellow.shade900, onTap: (){},number: stat.statistic.mapsTotal,),
                  StatisticsCard(icon:CupertinoIcons.clear, text:"Rendez-vous annulés",color: pink, onTap: (){},number: stat.statistic.rdvTotal! - stat.statistic.rdvDoneTotal!,),
                ]
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
