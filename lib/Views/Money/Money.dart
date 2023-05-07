import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/shimmer/gf_shimmer.dart';
import 'package:jiffy/jiffy.dart';
import 'package:monsalon_pro/models/MoneyModel.dart';
import 'package:provider/provider.dart';

import '../../Provider/StatisticsProvider.dart';
import '../../Theme/colors.dart';
import '../../utils/const.dart';


class MoneyScreen extends StatefulWidget {
  const MoneyScreen({Key? key, required this.color}) : super(key: key);
  final Color color;
  @override
  State<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends State<MoneyScreen> {
  bool done = false;
  bool error = false;

  Future<void> getCeMoisMoney() async {
    final provider =  Provider.of<StatisticsProvider>(context,listen: false);
    await provider.getCeMoisMoney(context).then((value){
      Timer(const Duration(seconds: 1), () {setState(() {done = true;});});
    }).catchError((onError){setState(() {done = true;error = true;});});
  }

  @override
  void initState() {
    super.initState();
    getCeMoisMoney();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Revenus",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600)),
        backgroundColor: widget.color,
        centerTitle: true,
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.arrow_back_rounded,color: Colors.white,)),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: size.height,
        width: size.width,
        child: !done ? Center(child: CircularProgressIndicator(color: widget.color, strokeWidth: 3,)) :
        ListView(
          children: [
            const SizedBox(height: 10,),
            Consumer<StatisticsProvider>(
                builder: (context, mon, child) {
                  if(mon.done != true) {
                    return const MoneyCardShemer();
                  }
                  return MoneyCard(money: mon.ceMoisMoney, mois : mon.currentMonth);
                }
            ),
            const NextBackMonth(),
          ],
        ),
      ),
    );
  }
}




class MoneyCard extends StatelessWidget {
  const MoneyCard({Key? key, required this.money, required this.mois}) : super(key: key);
  final Money money;
  final int mois;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14),),
      child: Container(
        height: 200,
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            etat(),
            const Spacer(flex: 2,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                money.prixFinCeMoins! > money.prixCeMois! ? "${formatPrice(money.prixCeMois!)} - ${formatPrice(money.prixFinCeMoins!)} DA" : "${formatPrice(money.prixCeMois!)} DA",
                style: const TextStyle(fontWeight: FontWeight.w600,color: Colors.white, fontSize: 30,),maxLines: 2,
              ),
            ),
            const Spacer(flex: 3,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                const Text("TOTAL :",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,),),
                const Spacer(),
                Text(
                  money.prixFinTotal! > money.prixTotal! ? "${formatPrice(money.prixTotal!)} - ${formatPrice(money.prixFinTotal!)} DA" : "${formatPrice(money.prixTotal!)} DA",
                  style: const TextStyle(fontWeight: FontWeight.w600,color: Colors.white,),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Row etat() {
    return Row(
      children: <Widget>[
        const Text("Ce mois-ci :",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,),),
        const Spacer(),
        Chip(
          side: const BorderSide(color: Colors.cyanAccent),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          padding: EdgeInsets.zero,
          backgroundColor: Colors.black,
          label: Row(
            children: [
              Text("${lesMois[Jiffy().subtract(months: mois).dateTime.month]}, ${Jiffy().subtract(months: mois).dateTime.year}",style: const TextStyle(color: Colors.cyanAccent,fontWeight: FontWeight.w600,), ),
              const SizedBox(width: 6,),
              const Icon(CupertinoIcons.calendar_today,color: Colors.cyanAccent),
            ],
          ),
        ),
      ],
    );
  }
}

class MoneyCardShemer extends StatelessWidget {
  const MoneyCardShemer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14),),
      child: Container(
        height: 200,
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _ceMois(),
            const Spacer(flex: 2,),
            const GFShimmer(mainColor: primaryLite2,child: Text( "xx - xx DA", style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white70, fontSize: 28,),maxLines: 2,)),
            const Spacer(flex: 3,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const[
                GFShimmer(mainColor: primaryLite2,child: Text("xxxx, 20xx",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,),)),
                Spacer(),
                GFShimmer(mainColor: primaryLite2,
                  child: Text("xx - xx DA",
                    style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white70,),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Row _ceMois() {
    return Row(
      children: <Widget>[
        const GFShimmer(mainColor: primaryLite2,child: Text("Ce mois-ci :",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,),)),
        const Spacer(),
        Chip(
          side: const BorderSide(color: primaryLite2,),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          padding: EdgeInsets.zero,
          backgroundColor: Colors.black,
          label: Row(
            children: const [
              GFShimmer(mainColor: primaryLite2,child: Text("xx xx",style: TextStyle(color:  Colors.tealAccent,fontWeight: FontWeight.w600,), )),
              SizedBox(width: 6,),
              GFShimmer(mainColor: primaryLite2,child: Icon(CupertinoIcons.calendar_today,color: Colors.tealAccent)),
            ],
          ),
        ),
      ],
    );
  }
}




class NextBackMonth extends StatefulWidget {
  const NextBackMonth({Key? key}) : super(key: key);

  @override
  State<NextBackMonth> createState() => _NextBackMonthState();
}

class _NextBackMonthState extends State<NextBackMonth> {
  bool hide = false ;
  @override
  Widget build(BuildContext context) {
    final provider =  Provider.of<StatisticsProvider>(context,listen: false);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          if(provider.currentMonth>0) Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed:(){
                  setState(() {
                    provider.subCurrentMonth();
                    hide= FirebaseAuth.instance.currentUser!.metadata.creationTime!.isAfter(Jiffy().subtract(months: provider.currentMonth).dateTime);
                  });
                  provider.getOtherMoisMoney(context);
                  },
                icon: Container(margin: const EdgeInsets.only(right: 3,top: 1,bottom: 1), child: const RotatedBox(quarterTurns: 2,child: Icon(CupertinoIcons.play_fill,color: Colors.white,size: 30,)),),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.only(top: 5,bottom: 5,right: 5,left: 4),
                  elevation: 10,
                ),
              ),
              const Text("  Suivant", style: TextStyle(fontWeight: FontWeight.w600),),
            ],
          ),
          const Spacer(),
          if(!hide) Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Précédent  ", style: TextStyle(fontWeight: FontWeight.w600),),
              IconButton(
                onPressed:(){
                  provider.addCurrentMonth();
                  setState(() {
                    hide = FirebaseAuth.instance.currentUser!.metadata.creationTime!.isAfter(Jiffy().subtract(months: provider.currentMonth+1).dateTime);
                  });
                  provider.getOtherMoisMoney(context);},
                icon: Container(margin: const EdgeInsets.only(left: 3,top: 1,bottom: 1),child: const Icon(CupertinoIcons.play_fill,color: Colors.white,size: 30,)),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.only(top: 5,bottom: 5,left: 5,right: 4),
                  elevation: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}




/*class MesCommissions extends StatelessWidget {
  const MesCommissions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsProvider>(
        builder: (context, provider, child) {
          if(provider.ceMoisMoney.commissionTotal == null || provider.done == false){
            return const SizedBox();
          }
          return Column(
            children: [
              const SizedBox(height: 20,),
              ListTile(
                //tileColor: Colors.black,
                leading: const Icon(Icons.discount_outlined,color: Colors.pink,),
                title: const Text("Commission :",style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16,color: Colors.black)),
                trailing: Text("${provider.ceMoisMoney.commission} %",style: const TextStyle(fontFamily: "Roboto",fontWeight: FontWeight.w600, color: Colors.pink,fontSize: 16,)),
              ),
              const SizedBox(height: 15,),

              ListTile(
                //tileColor: Colors.black,
                //shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                leading: const Icon(Icons.settings_suggest_outlined,color: Colors.pink,size: 26,),
                title: const Text("Frais de service :",style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16,color: Colors.black)),
                trailing: Text("${provider.ceMoisMoney.fraisDeService} DA / RDV",style: const TextStyle(fontFamily: "Roboto",fontWeight: FontWeight.w600, color: Colors.pink,fontSize: 16,)),
              ),
              const SizedBox(height: 15,),

              ListTile(
                //tileColor: Colors.black,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                leading: Icon(CupertinoIcons.creditcard,color: Colors.cyan.shade700,),
                title: const Text("Net à payer :",style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18,color: Colors.black,)),
                trailing: Text("${provider.ceMoisMoney.commissionTotal} DA",style: TextStyle(fontWeight: FontWeight.w600, color: Colors.cyan.shade700,fontSize: 18,fontFamily: "Roboto")),
              ),
              const SizedBox(height: 15,),

            ],
          );
        }
    );
  }
}*/










