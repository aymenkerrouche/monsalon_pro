import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:monsalon_pro/Widgets/SnaKeBar.dart';
import '../models/Team.dart';
import '../models/User.dart' as us;

class UserProvider extends ChangeNotifier {

  us.User expert = us.User("", "", "", "");
  bool expertDone = false;

  Future<void> getTeamInfo(BuildContext context) async {
    try{
      await FirebaseFirestore.instance.collection("team").where("userID",isEqualTo: FirebaseAuth.instance.currentUser?.uid).limit(1).get().then((snapshot){
        if(snapshot.docs.isNotEmpty){
          Team team = Team.fromJson(snapshot.docs.first.data());
          team.id = snapshot.docs.first.id;
          expert.team = team;
          expert.haveTeam = true;
        }
        else{
          expert.haveTeam = false;
        }
      });
    }
    catch(e){
      final snackBar = snaKeBar( e.toString(),);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      debugPrint(e.toString());
      expertDone = true;
    }
    expertDone = true;
    notifyListeners();
  }

  Future<void> getExpert(context) async {
    try{
      await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).get().then((snapshot){
        expert = us.User.fromJson(snapshot.data()!);
        expert.id = FirebaseAuth.instance.currentUser!.uid;
      });
    }
    on FirebaseException catch (e) {
      final snackBar = snaKeBar(e.message!);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    notifyListeners();
  }
}