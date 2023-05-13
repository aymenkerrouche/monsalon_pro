// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:monsalon_pro/utils/const.dart';
import 'package:provider/provider.dart';
import '../../Provider/AuthProvider.dart';
import '../../Theme/colors.dart';

class UpdateHours extends StatelessWidget {
  const UpdateHours({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Horaires de travail",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600)),
        backgroundColor: primary,
        centerTitle: true,
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.arrow_back_rounded,color: Colors.white,)),
      ),
      body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          height: size.height,
          width: size.width,
          child: const UpdateHoursBody()
      ),
    );
  }
}


class UpdateHoursBody extends StatefulWidget {
  const UpdateHoursBody({Key? key}) : super(key: key);

  @override
  State<UpdateHoursBody> createState() => _UpdateHoursBodyState();
}

class _UpdateHoursBodyState extends State<UpdateHoursBody> {
  bool next = false;
  bool done = false;

  Future<void> getInfos() async {
    final provider =  Provider.of<AuthProvider>(context,listen: false);
    await provider.getHours(FirebaseAuth.instance.currentUser?.uid).then((value){
      Timer(const Duration(milliseconds: 500), () {setState(() {done = true;});});
    });
  }

  @override
  void initState() {
    getInfos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if(auth.mySalon.hours == null || done == false) {
            return const Center(child: CircularProgressIndicator(color: primary, strokeWidth: 3,));
          }
          return Column(
            children: [
              Expanded(
                child: ListView(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20,),
                    const Text("Choisissez vos jours ouvrables",
                      style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 1), maxLines: 3,),
                    const SizedBox(height: 20,),
                    HourCard(day: 'dimanche',),
                    HourCard(day: 'lundi',),
                    HourCard(day: 'mardi', ),
                    HourCard(day: 'mercredi', ),
                    HourCard(day: 'jeudi', ),
                    HourCard(day: 'vendredi', ),
                    HourCard(day: 'samedi', ),
                    const SizedBox(height: 50,),
                  ],
                ),
              ),
              const SizedBox(height: 10,),
              ElevatedButton(
                onPressed: () async {
                  await Provider.of<AuthProvider>(context,listen: false).updateHours().then((value){
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
                    final snackBar = SnackBar(
                      elevation: 10,
                      backgroundColor: Colors.red.shade700,
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        onError.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  });
                },
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: primary,
                    elevation: 4,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)))
                ),
                child: SizedBox(
                  height: 52,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  [
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
    );

  }
}




class HourCard extends StatefulWidget {
  HourCard({Key? key,required this.day}) : super(key: key);
  String day;
  @override
  State<HourCard> createState() => _HourCardState();
}

class _HourCardState extends State<HourCard> {

  TextEditingController de = TextEditingController();
  TextEditingController a = TextEditingController();

  @override
  void initState() {
    getInfos();
    super.initState();
  }

  Future<void> getInfos() async {
    final provider =  Provider.of<AuthProvider>(context,listen: false);
    de.text = provider.mySalon.hours?.jours[widget.day]["start"];
    a.text = provider.mySalon.hours?.jours[widget.day]["fin"];
    startTime = TimeOfDay(hour: int.parse(de.text.split(":")[0]), minute: int.parse(de.text.split(":")[1]));
    endTime = TimeOfDay(hour: int.parse(a.text.split(":")[0]), minute: int.parse(a.text.split(":")[1]));
  }

  TimeOfDay? startTime;
  TimeOfDay? endTime ;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      child: Consumer<AuthProvider>(
          builder: (context, auth, child) {
            return ExpansionTile(
              title: Text(widget.day.toTitleCase(),style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w700),),
              trailing: IgnorePointer(
                child: CupertinoSwitch(
                  value: auth.mySalon.hours!.jours[widget.day]["active"],
                  activeColor: primary,
                  onChanged: (value){},
                ),
              ),
              textColor: primary,
              backgroundColor: primaryLite.withOpacity(.3),
              onExpansionChanged: (bool expanded) {auth.changeDays(widget.day,expanded);},
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 10,top: 20),
                  child: Row(
                    children: [
                      const SizedBox(width: 25,),
                      const Text("De"),

                      const SizedBox(width: 20,),
                      SizedBox(
                        width: 70,
                        height: 40,
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          readOnly: true,
                          controller: de,
                          onTap: () async {
                            TimeOfDay? pickedHour = await showTimePicker(
                              context: context,
                              cancelText: "Annuler".toUpperCase(),
                              helpText: "Sélectionner l'heure de début".toUpperCase(),
                              initialTime: TimeOfDay(hour:int.parse(de.text.split(":")[0]),minute: int.parse(de.text.split(":")[1])),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: dateColor,
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: primary, // button text color
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedHour != null) {

                              String heur = '${pickedHour.hour}';
                              String min = '${pickedHour.minute}';

                              if(pickedHour.hour < 10){heur ='0${pickedHour.hour}';}
                              if(pickedHour.minute < 10){min ='0${pickedHour.minute}';}

                              de.text = "$heur:$min";
                              auth.changeHours(widget.day,de.text,a.text);
                            }
                            setState(() {
                              startTime = TimeOfDay(hour: int.parse(de.text.split(":")[0]), minute: int.parse(de.text.split(":")[1]));
                              endTime = TimeOfDay(hour: int.parse(a.text.split(":")[0]), minute: int.parse(a.text.split(":")[1]));
                            });
                          },
                          cursorColor: primary,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                          decoration: InputDecoration(
                            hintText: "00:00",
                            hintStyle: const TextStyle(fontWeight: FontWeight.w600,color: primary,fontSize: 18),
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

                      const Text("à"),
                      const SizedBox(width: 20,),
                      SizedBox(
                        width: 70,
                        height: 40,
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          readOnly: true,
                          controller: a,
                          onTap: () async {
                            TimeOfDay? pickedHour = await showTimePicker(
                              context: context,
                              cancelText: "Annuler".toUpperCase(),
                              helpText: "Sélectionnez l'heure de fin".toUpperCase(),
                              initialTime: TimeOfDay(hour:int.parse(a.text.split(":")[0]),minute: int.parse(a.text.split(":")[1])),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: dateColor,
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: primary, // button text color
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedHour != null) {
                              String heur = '${pickedHour.hour}';
                              String min = '${pickedHour.minute}';

                              if(pickedHour.hour < 10){heur ='0${pickedHour.hour}';}
                              if(pickedHour.minute < 10){min ='0${pickedHour.minute}';}

                              a.text = "$heur:$min";
                              auth.changeHours(widget.day,de.text,a.text);
                            }
                            setState(() {
                              startTime = TimeOfDay(hour: int.parse(de.text.split(":")[0]), minute: int.parse(de.text.split(":")[1]));
                              endTime = TimeOfDay(hour: int.parse(a.text.split(":")[0]), minute: int.parse(a.text.split(":")[1]));
                            });
                          },
                          cursorColor: primary,
                          style: TextStyle(fontWeight: FontWeight.w700,color: startTime!.hour > endTime!.hour || (startTime!.hour == endTime!.hour && startTime!.minute > endTime!.minute) ? Colors.red : Colors.black),
                          decoration: InputDecoration(
                            hintText: "00:00",
                            hintStyle: const TextStyle(fontWeight: FontWeight.w600,color: primary,fontSize: 18),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: startTime!.hour > endTime!.hour || (startTime!.hour == endTime!.hour && startTime!.minute > endTime!.minute) ? Colors.red : primary, width: .5),
                                gapPadding: 6),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: startTime!.hour > endTime!.hour || (startTime!.hour == endTime!.hour && startTime!.minute > endTime!.minute) ? Colors.red : clr3.withOpacity(.5), width: .5),
                                gapPadding: 6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 25,),
                    ],
                  ),
                )
              ],
            );
          }
      ),
    );
  }
}


