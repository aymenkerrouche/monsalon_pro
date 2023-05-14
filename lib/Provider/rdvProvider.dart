import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:monsalon_pro/Widgets/SnaKeBar.dart';
import 'package:monsalon_pro/models/Service.dart';
import '../models/Hours.dart';
import '../models/RendezVous.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/Salon.dart';
import '../utils/const.dart';

class RdvProvider extends ChangeNotifier {

  /* ETAT
  0 en attente
  1 accepté
  2 annulé
  3 terminé
  -1 refusé
  -2 litige
  */

  List<RendezVous> listRDV = [];
  List<RendezVous> listDemandes = [];
  Map<String,dynamic> rdvMap = {} ;
  RendezVous? rdv;
  bool done = false;

  Future<void> getDemandes(context,String salonID) async {
    listDemandes.clear();
    done = false;
    await FirebaseFirestore.instance.collection("rdv")
    .where("salonID",isEqualTo:  salonID)
    .where("etat",isEqualTo: 0)
    .where("date2", isGreaterThanOrEqualTo: DateTime.now().subtract(const Duration(days: 1))).orderBy("date2")
    .get().then((snapshot){
      if(snapshot.docs.isNotEmpty){
        for (var element in snapshot.docs) {
          RendezVous rdv = RendezVous.fromJson(element.data());
          rdv.id = element.id;
          if(element.data()["service"] != null){
            for (var srv in element.data()["service"]) {
              rdv.services.add(Service.fromJson(srv));
            }
          }

          listDemandes.add(rdv);
          notifyListeners();
        }
      }
    })
    .catchError((onError){
      debugPrint(onError.toString());
      done = false;
      final snackBar = snaKeBar(onError.toString());
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      notifyListeners();
    });
    done = true;
    notifyListeners();
  }

  Future<void> deleteDemande(String salonID,String rdvID, String userID) async {
    try{
      await FirebaseFirestore.instance.collection("rdv").doc(rdvID).update({
        "etat": -1,
      });
      listDemandes.removeWhere((element) => element.id == rdvID);
      await getUserToken(userID,rdvID,"Le salon a refusé votre rendez-vous.","Rendez-vous refusé");
    }
    catch(e){
      debugPrint(e.toString());
    }

    notifyListeners();
  }

  Future<void> acceptDemande(String rdvID,String userID, int prix, int prixFin,context, Timestamp rdvDate,String salonID) async {
    try{
      await FirebaseFirestore.instance.collection("statistics").doc( salonID).update({
        "prixTotal": FieldValue.increment(prix),
        "prixFinTotal" : FieldValue.increment(prixFin),
        "prix${rdvDate.toDate().year}.${rdvDate.toDate().month}":FieldValue.increment(prix),
        "prixFin${rdvDate.toDate().year}.${rdvDate.toDate().month}":FieldValue.increment(prixFin),
        "rdv${rdvDate.toDate().year}.${rdvDate.toDate().month}done":FieldValue.increment(1),
        "rdvDone":FieldValue.increment(1),
      });
      await FirebaseFirestore.instance.collection("rdv").doc(rdvID).update({
        "etat": 1,
      });
      listDemandes.removeWhere((element) => element.id == rdvID);
      await getUserToken(userID,rdvID,"Le salon a accepté votre rendez-vous.","Rendez-vous accepté");
    }
    catch(e){
      debugPrint(e.toString());
      final snackBar = snaKeBar(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    notifyListeners();
  }





  Future<void> getRDV(context,salonID,chosenValue) async {
    listRDV.clear();
    done = false;
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection("rdv")
        .where("salonID",isEqualTo: salonID)
        .where("etat",isEqualTo: 1)
        .where("date2", isGreaterThanOrEqualTo: DateTime.now().subtract(const Duration(days: 1))).orderBy("date2");
    switch(chosenValue) {
      case "Tous": {
        query = await FirebaseFirestore.instance.collection("rdv").where("salonID",isEqualTo: salonID);
      }
      break;

      case 'Prochains': {
        query = FirebaseFirestore.instance.collection("rdv")
            .where("salonID",isEqualTo: salonID)
            .where("etat",isEqualTo: 1)
            .where("date2", isGreaterThanOrEqualTo: DateTime.now().subtract(const Duration(days: 1))).orderBy("date2");
      }
      break;

      case 'Terminé': {
        query = FirebaseFirestore.instance.collection("rdv")
                .where("salonID",isEqualTo: salonID)
                .where("etat",isEqualTo: 3)
                .where("date2", isLessThanOrEqualTo: DateTime.now()).orderBy("date2");
      }
      break;

      case 'Annulé': {
        query = FirebaseFirestore.instance.collection("rdv")
            .where("salonID",isEqualTo: salonID)
            .where("etat",whereIn: [2, -1]);
      }
      break;

      case 'Récent': {
        query = FirebaseFirestore.instance.collection("rdv")
            .where("salonID",isEqualTo: salonID)
            .orderBy("date2",descending: true);
      }
      break;

      case 'Ancien': {
        query = FirebaseFirestore.instance.collection("rdv")
            .where("salonID",isEqualTo: salonID)
            .orderBy("date2");
      }
      break;

      default: {
        query = FirebaseFirestore.instance.collection("rdv")
            .where("salonID",isEqualTo: salonID)
            .where("etat",isEqualTo: 1)
            .where("date2", isGreaterThanOrEqualTo: DateTime.now().subtract(const Duration(days: 1))).orderBy("date2");
      }
      break;
    }

    await query.get().then((snapshot){
      if(snapshot.docs.isNotEmpty){
        for (var element in snapshot.docs) {
          RendezVous rdv = RendezVous.fromJson(element.data());
          rdv.id = element.id;
          if(element.data()["service"] != null){
            for (var srv in element.data()["service"]) {
              rdv.services.add(Service.fromJson(srv));
            }
          }
          listRDV.add(rdv);
          notifyListeners();
        }
      }
    })
    .catchError((onError){
      debugPrint(onError.toString());
      done = false;
      final snackBar = snaKeBar(onError.toString());
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      notifyListeners();
    });
    done = true;
    notifyListeners();
  }

  Future<void> deleteRDV(String rdvID, String userID,context,Timestamp rdvDate,int prix, int prixFin,String salonID) async {
    try{
      await FirebaseFirestore.instance.collection("statistics").doc(salonID).update({
        "rdv${rdvDate.toDate().year}.${rdvDate.toDate().month}done":FieldValue.increment(-1),
        "rdvDone":FieldValue.increment(-1),

        "prixTotal": FieldValue.increment(-prix),
        "prixFinTotal" : FieldValue.increment(-prixFin),
        "prix${rdvDate.toDate().year}.${rdvDate.toDate().month}":FieldValue.increment(-prix),
        "prixFin${rdvDate.toDate().year}.${rdvDate.toDate().month}":FieldValue.increment(-prixFin),


      });
      await FirebaseFirestore.instance.collection("rdv").doc(rdvID).update({
        "etat": 2,
      });
      listRDV.removeWhere((element) => element.id == rdvID);
      await getUserToken(userID,rdvID,"Nous sommes désolés de vous informer que votre rendez-vous a été annulé.","Rendez-vous annulé");
    }
    catch(onError){
      final snackBar = snaKeBar(onError.toString());
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      debugPrint(onError.toString());
    }
    notifyListeners();
  }

  Future<void> terminerRDV(String rdvID,String userID,context) async {
    try{
      await FirebaseFirestore.instance.collection("rdv").doc(rdvID).update({
        "etat": 3,
      });
      listDemandes.removeWhere((element) => element.id == rdvID);
      await getUserToken(userID,rdvID,"Nous souhaitons que vous ayez eu une expérience formidable, Notez le salon et laissez un commentaire","Rendez-vous terminé");
    }
    catch(e){
      debugPrint(e.toString());
      final snackBar = snaKeBar(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    notifyListeners();
  }




  getUserToken(String userID, String rdvID,String body, String title) async {
    await FirebaseFirestore.instance.collection("users").doc(userID).get().then((value) async {
      if(value.exists){
        if(value.data()!.isNotEmpty){
          await sendPushMessage(value.get("token"),rdvID,userID,body,title);
        }
      }
    });
  }

  Future<void> sendPushMessage(String token, String rdvID, String userID, String body, String title) async {
    String serverToken = "AAAA_zv9Bzo:APA91bFHW72_Q55L2tgImKoSrFUDWRI9NAmftCmsKiB2SLpJ1IJ5JV8rbxuXLj32E9a0Xx_YvaQV2c7FaPkZaNsiYhkTCznakDolzHoDV7MW-_OJarNiSNhwHD2BhgdO1VOFcj_WRAxB";
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': rdvID,
              "userID" : userID
            },
            "to": token,
          },
        ),
      );
      debugPrint('done');
    } catch (e) {
      debugPrint('error push notification');
    }
  }






  // CREATE RDV

  List<String> heures = [];
  List<String> heuresSHIMER = ['10:00', '10:30', '11:00', '11:30', '12:00', '12:30', '13:00', '13:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30', '17:00'];

  String _selectedHour = '';
  String get selectedHour => _selectedHour;

  String _selectedDay = 'Selectionnez une date';
  String get selectedDay => _selectedDay;


  set selectedHour(String heure) {
    _selectedHour = heure;
    notifyListeners();
  }

  set selectedDay(String day) {
    _selectedDay = day;
    notifyListeners();
  }

  getHours(DateTime pickedDay, Hours hours) {
    heures.clear();
    _selectedHour = '';

    String start = hours.jours[weekdayName[pickedDay.weekday]]["start"];
    String end = hours.jours[weekdayName[pickedDay.weekday]]["fin"];

    DateTime dateTimeStart = dateFormat.parse("${DateFormat("dd-MM-yyyy").format(pickedDay)} $start");
    DateTime dateTimeEnd = dateFormat.parse("${DateFormat("dd-MM-yyyy").format(pickedDay)} $end");
    DateTime dateTimeTemp = dateTimeStart;

    while (dateTimeTemp.isBefore(dateTimeEnd)) {
      heures.add(DateFormat.Hm().format(dateTimeTemp));
      dateTimeTemp = dateTimeTemp.add(const Duration(minutes: 30));
    }

    notifyListeners();
  }

  clear() {
    _selectedHour = '';
    _selectedDay = "Selectionnez une date";
    heures.clear();
    rdvMap.clear();
    //notifyListeners();
  }

  Future<void> fillRDV(Salon salon, String phone, String name,List<Service> services, teamController,) async {

    int prix = 0;
    int prixFin = 0;

    for (var element in services) {
      prix += element.prix!;
      prixFin += element.prixFin == 0 ? element.prix! : element.prixFin!;
    }

    String dateTemp = _selectedDay.split(" ").last;
    DateTime date2 = DateFormat('dd-MM-yyyy, HH:mm').parse('$dateTemp, $selectedHour');

    rdvMap = {
      "salon": salon.nom,
      "salonID": salon.id,
      "comment": '',
      "duree": 30,
      "prix" : prix,
      "date" : _selectedDay,
      "date2" : Timestamp.fromDate(date2),
      "hour" : selectedHour,
      "prixFin" : prixFin,
      "etat": 1,
      "service" : services,
      "location": salon.location,
      "remise": salon.promo == true? salon.remise : 0,
      "user": name,
      "userID": "1",
      "userPhone": phone,
    };
    if(teamController.selectedItem != null){
      if (teamController.selectedItem.name != "N'importe qui") {
        rdvMap["team"] = true;
        rdvMap["teamInfo"] = {
          "name": teamController.selectedItem.name,
          "userID": teamController.selectedItem.userID,
        };
      }
    }
    else {
      rdvMap["team"] = false;
      rdvMap['teamInfo'] = null;
    }
    print(rdvMap);
    rdv = RendezVous.fromJson(rdvMap);
    rdvMap["service"] = [];
    for (var element in services) {
      rdvMap["service"].add(element.toJson());
    }
    rdv?.services = services;
    notifyListeners();
  }

  Future<bool> createRDV(context,String salonID) async {
    try {
      await FirebaseFirestore.instance.collection("rdv").add(rdvMap).then((value) async {
        await FirebaseFirestore.instance.collection("statistics").doc(salonID).update({
          "rdvTotal": FieldValue.increment(1),
          "rdv${DateTime.now().year}.${DateTime.now().month}": FieldValue.increment(1)
        });
        if (rdv!.services.isNotEmpty) {
          for (var element in rdv!.services) {
            await FirebaseFirestore.instance.collection("statistics").doc(salonID).update({
              "services.${element.service}": FieldValue.increment(1),
            });
          }
        }
      });
      final snackBar = snaKeBarDone("Rendez-vous bien créé");
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return true;
    } on FirebaseException catch (e) {
      debugPrint(e.toString());
      final snackBar =  snaKeBar("${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
  }


}
