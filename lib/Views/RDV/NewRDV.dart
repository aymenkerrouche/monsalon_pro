// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:checkbox_grouped/checkbox_grouped.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:getwidget/components/shimmer/gf_shimmer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Provider/AuthProvider.dart';
import '../../Provider/UserProvider.dart';
import '../../Provider/rdvProvider.dart';
import '../../Theme/colors.dart';
import '../../Widgets/keyboard.dart';
import '../../Widgets/phone TextField.dart';
import '../../main.dart';
import '../../models/Hours.dart';
import '../../models/Service.dart';
import '../../models/Team.dart';
import '../../utils/const.dart';
import '../Demandes/Facture.dart';



class CreateRdv extends StatefulWidget {
  const CreateRdv({Key? key}) : super(key: key);

  @override
  State<CreateRdv> createState() => _CreateRdvState();
}

class _CreateRdvState extends State<CreateRdv> {
  @override
  void initState() {
    getServices().then((value) => setState(() {done = true;}));
    super.initState();
  }

  Future<void> getServices() async {
    final provider = Provider.of<AuthProvider>(context,listen: false);
    Provider.of<RdvProvider>(context,listen: false).clear();
    String salonID = '';

    if(prefs?.getBool("expertMode") == true){
      salonID = Provider.of<UserProvider>(context,listen: false).expert.team!.salonID!;
      await provider.getInfos(context, salonID);
    }
    else{
      salonID = FirebaseAuth.instance.currentUser!.uid;
    }

    await provider.getExperts(context,salonID);
    await provider.getSalonCategoriesAndServices(salonID);
    await provider.getHours(salonID);
  }

  bool done = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(onTap: () {FocusScope.of(context).unfocus();KeyboardUtil.hideKeyboard(context);},
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Créer un rendez-vous",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,)),
          backgroundColor: primary,
          elevation: 10,
          leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.arrow_back_rounded,color: Colors.white,)),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: size.height,
          width: size.width,
          child: done ? const CreateRdvBody():
          const Center(child: CircularProgressIndicator(color: primary,strokeWidth: 3,),),
        )
      ),
    );
  }
}





class CreateRdvBody extends StatefulWidget {
  const CreateRdvBody({Key? key}) : super(key: key);

  @override
  State<CreateRdvBody> createState() => _CreateRdvBodyState();
}

class _CreateRdvBodyState extends State<CreateRdvBody> {
  GroupController serviceController = GroupController(isMultipleSelection: true);
  GroupController teamController = GroupController();

  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();

  bool click = false;
  bool tlpn = false;

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context,listen: false);
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20,),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/user1.svg", width: 16, color: primary,),
                const SizedBox(width: 10,),
                const Flexible(child: Text("Entrez les information du client",maxLines: 2,style: TextStyle(fontWeight: FontWeight.w600),)),
              ],
            ),
          ),
          const SizedBox(height: 20,),
          TextInfomation(textController: name,hint:"le nom",label: "Nom",icon: CupertinoIcons.person_alt_circle,textType: TextInputType.text),

          Column(
            children: [
              if(!tlpn) const SizedBox(height: 20,),
              if(!tlpn) TextInfomation(textController: phone,hint:"05 .. .. ..",label: "Téléphone",icon: CupertinoIcons.phone,textType: TextInputType.phone),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                width: size.width,
                child: Row(
                  children: [
                    const Text("le client n'a pas de téléphone",style: TextStyle(fontSize: 12,),textAlign: TextAlign.start,),
                    Checkbox(
                      value: tlpn,
                      onChanged: (value) {
                        setState(() {
                          tlpn = value!;
                          if(value == true){
                            FocusScope.of(context).unfocus();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20,),
          servicesList(serviceController,provider.mySalon.service),

          const SizedBox(height: 20,),

          if(provider.mySalon.teams.isNotEmpty) teamList(teamController,provider.mySalon.teams),

          if(provider.mySalon.teams.isNotEmpty) const SizedBox(height: 50,),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/history.svg", width: 16, color: primary,),
                const SizedBox(width: 10,),
                const Flexible(child: Text("Choisissez la date et l'heure",maxLines: 2,)),
              ],
            ),
          ),
          const SizedBox(height: 20,),

          PickDay(hours: provider.mySalon.hours!),
          const SizedBox(height: 10,),

          const PickHour(),
          const SizedBox(height: 20,),


          // BOOK
          ElevatedButton(
            onPressed:() async {
              final provider2 = Provider.of<RdvProvider>(context,listen: false);
              setState((){click = true;});
              if (serviceController.selectedItem.isNotEmpty) {
                provider2.fillRDV( provider.mySalon, phone.text, name.text, serviceController.selectedItem, teamController)
                    .then((value) => Timer(const Duration(milliseconds: 200),()=>
                    Navigator.push(context, CupertinoPageRoute(builder: (context) => FactureScreen(rdv: provider2.rdv!, color: primaryLite2,createRDV: true,)),)));
              }
              setState((){click = false;});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryLite2,
              fixedSize: const Size(double.maxFinite, 50),
              elevation: 4,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Sauvegarder', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22,color: Colors.white,letterSpacing: 1),),
                const SizedBox(width: 15,),
                click ? const SizedBox(height: 25,width: 25,child: CircularProgressIndicator(color: Colors.white,strokeWidth: 3,),) :
                const Icon(Icons.check_rounded,size: 26,color: Colors.white,)
              ],
            ),
          ),


          const SizedBox(height: kToolbarHeight,)
        ],
      ),
    );
  }

  Widget teamList(teamController,List<Team> teams){
    return Column(
      children: [
      /*
       Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: const [
                    Icon(CupertinoIcons.group,color: primary,),
                    SizedBox(width: 10,),
                    Flexible( child:Text("Choisissez l’expert avec qui vous êtes à l’aise",maxLines: 2,style: TextStyle(fontWeight: FontWeight.w600),),),
                  ],
                ),
              ),
      */
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          child: SimpleGroupedCheckbox<Team>(
            controller: teamController,
            groupTitle: 'Nos Experts',
            groupTitleAlignment: Alignment.centerLeft,
            helperGroupTitle: false,
            isExpandableTitle: true,
            itemsTitle: teams.map((e) => e.name!).toList(),
            values: teams.toList(),
            groupStyle: GroupStyle(
              activeColor: primary,
              itemTitleStyle: const TextStyle(fontSize: 16),
              groupTitleStyle: const TextStyle(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.black,),
            ),
            checkFirstElement: true,
          ),
        ),

      ],
    );
  }

  Widget servicesList(serviceController, service){
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            children: [
              SvgPicture.asset("assets/icons/cut.svg", width: 16, color: primary,),
              const SizedBox(width: 10,),
              const Flexible(child: Text("Choisissez les prestations",maxLines: 2,style: TextStyle(fontWeight: FontWeight.w600),)),
            ],
          ),
        ),
        const SizedBox(height: 10,),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          child: SimpleGroupedCheckbox<Service>(
            controller: serviceController,
            groupTitle: "Prestations",
            groupTitleAlignment: Alignment.centerLeft,
            helperGroupTitle: false,
            isExpandableTitle: true,
            itemsTitle: List.generate(service.length, (index) => "${service[index].service}"),
            itemsSubTitle: List.generate(service.length, (index) => service[index].prixFin == 0 ?
            "${service[index].prix} DA" : "${service[index].prix} - ${service[index].prixFin} DA"
            ),
            values: service.toList(),
            groupStyle: GroupStyle(
              activeColor: primary,
              itemTitleStyle: const TextStyle(fontSize: 16),
              groupTitleStyle: const TextStyle(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.black,),
            ),
            checkFirstElement: false,
          ),
        ),

      ],
    );
  }
}




class PickDay extends StatelessWidget {
  PickDay({Key? key, required this.hours}) : super(key: key);
  DateTime selectedDay = DateTime.now().add(const Duration(days: 1));
  final Hours hours;
  @override
  Widget build(BuildContext context){
    final provider = Provider.of<RdvProvider>(context,listen: false);
    return  StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return  Material(
            borderRadius: const BorderRadius.all(Radius.circular(14)),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(14)),
              splashColor: primaryLite,
              onTap: () async {
                bool ok = false;
                while(ok == false){
                  if(
                  (selectedDay.weekday == 7 && hours.jours["dimanche"]["active"]  == false ) == true ||
                      (selectedDay.weekday == 1 && hours.jours['lundi']["active"]  == false)  == true ||
                      (selectedDay.weekday == 2 && hours.jours["mardi"]["active"]  == false)  == true ||
                      (selectedDay.weekday == 3 && hours.jours["mercredi"]["active"]  == false)  == true ||
                      (selectedDay.weekday == 4 && hours.jours["jeudi"]["active"]  == false)  == true ||
                      (selectedDay.weekday == 5 && hours.jours["vendredi"]["active"] == false)  == true ||
                      (selectedDay.weekday == 6 && hours.jours["samedi"]["active"]  == false) == true
                  )
                  {setState((){selectedDay = selectedDay.add(const Duration(days: 1));});}

                  else{setState((){ok = true;});}
                }

                bool decideWhichDayToEnable(DateTime date) {
                  if (date.weekday == 7 && hours.jours["dimanche"]["active"] == true) {
                    return true;
                  }
                  if (date.weekday == 1 && hours.jours['lundi']["active"] == true) {
                    return true;
                  }
                  if (date.weekday == 2 && hours.jours["mardi"]["active"] == true ) {
                    return true;
                  }
                  if (date.weekday == 3 &&hours.jours["mercredi"]["active"] == true ) {
                    return true;
                  }
                  if (date.weekday == 4 && hours.jours["jeudi"]["active"] == true ) {
                    return true;
                  }
                  if (date.weekday == 5 && hours.jours["vendredi"]["active"] == true ) {
                    return true;
                  }
                  if (date.weekday == 6 && hours.jours["samedi"]["active"] == true ) {
                    return true;
                  }
                  return false;
                }

                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  locale: const Locale("fr", "FR"),
                  initialDate: selectedDay,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 120)),
                  selectableDayPredicate: decideWhichDayToEnable,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: primary,
                          surfaceTint: Colors.white,
                        ),
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

                if (pickedDate != null) {
                  setState((){selectedDay = pickedDate;});
                  provider.getHours(pickedDate,hours);
                  provider.selectedDay = "${weekdayName[pickedDate.weekday]} ${DateFormat('dd-MM-yyyy').format(pickedDate)}";
                }
              },
              child: ListTile(
                title: Text(provider.selectedDay,style: const TextStyle(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.black,),),
                trailing: const Icon(CupertinoIcons.calendar, color: primary,),
                tileColor: const Color(0xFFFDF9FF),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14)),),
              ),
            ),
          );
        });
  }
}

class PickHour extends StatelessWidget {
  const PickHour({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Consumer<RdvProvider>(
          builder: (context, rdv, child){
            if(rdv.heures.isNotEmpty){
              return ListView.builder(
                itemCount: rdv.heures.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context,index){
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: FilterChip(
                      label: Text(rdv.heures[index],style: TextStyle(color: rdv.selectedHour == rdv.heures[index] ? Colors.white : primaryPro,fontSize: 16),),
                      selected: rdv.selectedHour == rdv.heures[index] ? true : false,
                      onSelected: (v){
                        if(v == true){
                          rdv.selectedHour = rdv.heures[index];
                        }
                        else{
                          rdv.selectedHour = '';
                        }
                      },
                      backgroundColor: primaryLite.withOpacity(.3),
                      selectedColor: primaryLite2,
                      side: BorderSide.none,
                      checkmarkColor: Colors.white,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                    ),
                  );
                },
              );
            }
            return ListView.builder(
              itemCount: rdv.heuresSHIMER.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context,index){
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: Chip(
                    label: GFShimmer(mainColor: primaryLite2,child: Text(rdv.heuresSHIMER[index],style: const TextStyle(color:primaryPro,fontSize: 16),)),
                    backgroundColor: primaryLite.withOpacity(.3),
                    side: BorderSide.none,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                  ),
                );
              },
            );
          }
      ),
    );
  }
}

