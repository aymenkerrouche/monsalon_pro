
import 'package:firebase_auth/firebase_auth.dart';

class Statistic {
  String? id;
  int? vueTotal;
  int? vue;
  int? mapsTotal;
  int? maps;
  int? tlpnTotal;
  int? tlpn;
  int? rdvTotal;
  int? rdvDoneTotal;
  int? rdv;
  int? rdvDone;
  int? favorites;
  Map<String,dynamic> services = {} ;

  Statistic(this.id,this.vueTotal, this.vue, this.favorites, this.maps, this.mapsTotal, this.tlpn, this.services ,this.tlpnTotal, this.rdv,this.rdvTotal,this.rdvDone,this.rdvDoneTotal);

  Statistic.fromJson(Map<String, dynamic> json){

    id = FirebaseAuth.instance.currentUser?.uid;

    vueTotal = json['vuTotal'] ?? 0 ;

    try{
      vue = json["vu${DateTime.now().year}"]["${DateTime.now().month}"] ?? 0 ;
    }
    catch(e){
      vue =  0 ;
    }


    mapsTotal = json['mapsTotal'] ?? 0 ;

    try{
      maps = json["maps${DateTime.now().year}"]["${DateTime.now().month}"] ?? 0 ;
    }
    catch(e){
      maps = 0 ;
    }

    tlpnTotal = json['tlpnTotal'] ?? 0 ;
    try{
      tlpn = json["tlpn${DateTime.now().year}"]["${DateTime.now().month}"] ?? 0 ;
    }
    catch(e){
      tlpn =  0 ;
    }


    rdvTotal = json['rdvTotal'] ?? 0 ;
    try{
      rdv = json["rdv${DateTime.now().year}"]["${DateTime.now().month}"] ?? 0 ;
    }
    catch(e) {
      rdv = 0;
    }

    try{
      rdvDone = json["rdv${DateTime.now().year}"]["${DateTime.now().month}done"] ?? 0 ;
    }
    catch(e){
      rdvDone =  0 ;
    }
    rdvDoneTotal = json["rdvDone"] ?? 0 ;

    favorites = json['favorites'] ?? 0 ;

    services = json["services"] ?? {};
  }
}