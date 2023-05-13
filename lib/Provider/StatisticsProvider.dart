import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:monsalon_pro/models/MoneyModel.dart';
import '../Widgets/SnaKeBar.dart';
import '../models/Statistics.dart';


class StatisticsProvider extends ChangeNotifier {

  Statistic statistic = Statistic.fromJson({});
  Money ceMoisMoney = Money.fromJson({});
  int currentMonth = 0;

  bool done = false;

  Future<void> getStatistics(context) async {
    done = false;
    await FirebaseFirestore.instance.collection("statistics").doc(FirebaseAuth.instance.currentUser?.uid).get().then((snapshot) async {
      statistic = Statistic.fromJson({});
      if(snapshot.exists){
        statistic = Statistic.fromJson(snapshot.data()!);
        var sortedByValueMap = Map.fromEntries(statistic.services.entries.toList()..sort((e1, e2) => e2.value.compareTo(e1.value)));
        statistic.services = sortedByValueMap;
      }
      else{
        await FirebaseFirestore.instance.collection("statistics").doc(FirebaseAuth.instance.currentUser?.uid).set({"vuTotal" : 1});
      }
    })
    .catchError((onError){
      debugPrint(onError.toString());
      done = true;
      final snackBar = snaKeBar(onError.toString(),);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      notifyListeners();
    });
    done = true;
    notifyListeners();
  }

  Future<void> getCeMoisMoney(context) async {
    currentMonth = 0;
    done = false;
    try{
      await FirebaseFirestore.instance.collection("statistics").doc(FirebaseAuth.instance.currentUser?.uid).get().then((snapshot){
        if(snapshot.exists){
          ceMoisMoney = Money.fromJson(snapshot.data()!);
        }
      });
    }
    catch(onError){
      debugPrint(onError.toString());
      done = true;
      final snackBar = snaKeBar(onError.toString(),);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      notifyListeners();
    }
    done = true;
    notifyListeners();
  }

  Future<void> getOtherMoisMoney(context) async {
    done = false;
    notifyListeners();

    int todayMonth = DateTime.now().month;
    int todayYear = DateTime.now().year;

    todayMonth = Jiffy().subtract(months: currentMonth).dateTime.month;
    todayYear = Jiffy().subtract(months: currentMonth).dateTime.year;

    Timer(const Duration(seconds: 1), () async {
      try{
        await FirebaseFirestore.instance.collection("statistics").doc(FirebaseAuth.instance.currentUser?.uid).get().then((snapshot){
          if(snapshot.exists){
            ceMoisMoney = Money.fromJson(snapshot.data()!);
            try{
              ceMoisMoney.prixCeMois = snapshot.data()!["prix$todayYear"]["$todayMonth"] ?? 0 ;
            }
            catch(e){
              ceMoisMoney.prixCeMois = 0 ;
            }

            try{
              ceMoisMoney.prixFinCeMoins = snapshot.data()!["prixFin$todayYear"]["$todayMonth"] ?? 0 ;
            }
            catch(e){
              ceMoisMoney.prixFinCeMoins = 0 ;
            }

            try{
              ceMoisMoney.rdv = snapshot.data()!["rdv$todayYear"]["${todayMonth}done"] ?? 0 ;
            }
            catch(e) {
              ceMoisMoney.rdv = 0;
            }

            try{
              ceMoisMoney.etatCeMois = snapshot.data()!["etat$todayYear"]["$todayMonth"] ?? 0 ;
            }
            catch(e){
              ceMoisMoney.etatCeMois = 0 ;
            }
          }
        });
      }
      catch(onError){
        debugPrint(onError.toString());
        done = true;
        final snackBar = snaKeBar(onError.toString(),);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        notifyListeners();
      }
      done = true;
      notifyListeners();
    });
  }

  addCurrentMonth(){
    currentMonth++;
    notifyListeners();
  }
  subCurrentMonth(){
    currentMonth--;
    notifyListeners();
  }
}