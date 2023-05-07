import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:monsalon_pro/models/MoneyModel.dart';
import '../models/Statistics.dart';


class StatisticsProvider extends ChangeNotifier {

  late Statistic statistic;
  late Money ceMoisMoney;
  int currentMonth = 0;

  bool done = false;

  Future<void> getStatistics(context) async {
    done = false;
    await FirebaseFirestore.instance.collection("statistics").doc("ZAoUYwsrjqpVXCDbqqRM"/*FirebaseAuth.instance.currentUser?.uid*/).get().then((snapshot){
      if(snapshot.exists){
        statistic = Statistic.fromJson(snapshot.data()!);
        var sortedByValueMap = Map.fromEntries(statistic.services.entries.toList()..sort((e1, e2) => e2.value.compareTo(e1.value)));
        statistic.services = sortedByValueMap;
      }
    })
    .catchError((onError){
      debugPrint(onError.toString());
      done = true;
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
      notifyListeners();
    });
    done = true;
    notifyListeners();
  }

  Future<void> getCeMoisMoney(context) async {
    currentMonth = 0;
    done = false;
    try{
      await FirebaseFirestore.instance.collection("statistics").doc("ZAoUYwsrjqpVXCDbqqRM"/*FirebaseAuth.instance.currentUser?.uid*/).get().then((snapshot){
        if(snapshot.exists){
          ceMoisMoney = Money.fromJson(snapshot.data()!);
        }
      }).then((value) async => await getCommissions());
    }
    catch(onError){
      debugPrint(onError.toString());
      done = true;
      final snackBar = SnackBar(
        elevation: 10,
        behavior: SnackBarBehavior.floating,
        content: Text(
          onError.toString(),
          style: const TextStyle(color: Colors.white),
        ),
      );
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
        await FirebaseFirestore.instance.collection("statistics").doc("ZAoUYwsrjqpVXCDbqqRM"/*FirebaseAuth.instance.currentUser?.uid*/).get().then((snapshot){
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
        }).then((value) async {
          if(todayMonth == DateTime.now().month && todayYear == DateTime.now().year){
            await getCommissions();
          }
        });
      }
      catch(onError){
        debugPrint(onError.toString());
        done = true;
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


  Future<void> getCommissions() async {
    try{
      await FirebaseFirestore.instance.collection("commission").doc("commission").get().then((snapshot){
        if(snapshot.exists){
          ceMoisMoney.fraisDeService = snapshot.data()!["fraisDeService"] ?? 0 ;
          ceMoisMoney.commission = snapshot.data()!["commission"] ?? 0 ;
          ceMoisMoney.commissionTotal = (ceMoisMoney.prixCeMois! * (ceMoisMoney.commission!/100)) + (ceMoisMoney.fraisDeService! * ceMoisMoney.rdv!) ;
        }
      });
    }
    catch(onError){
      debugPrint(onError.toString());
    }
    notifyListeners();
  }


}