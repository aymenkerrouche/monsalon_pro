import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monsalon_pro/models/Service.dart';
import 'Team.dart';

class RendezVous {
  String? id;
  String? date;
  Timestamp? date2;
  String? hour;
  int? etat;
  String? salonID;
  String? salon;
  String? userID;
  String? user;
  int? duree;
  int? prix;
  int? prixFin;
  String? comment;
  int? remise;
  bool? team;
  Team? teamInfo;
  List<Service> services = [];
  String? location;
  String? userPhone;

  RendezVous(this.id, this.team, this.date2 ,this.prixFin,this.userPhone,this.location,this.teamInfo,this.comment, this.date, this.remise,this.salonID,this.hour, this.etat, this.salon, this.user, this.userID,this.duree, this.prix);

  RendezVous.fromJson(Map<String, dynamic> json){
    userID = json['userID'] ?? '';
    salonID = json['salonID'] ?? '';
    date = json['date'] ?? '';
    date2 = json['date2'];
    hour = json['hour'] ?? '';
    etat = json["etat"] ??  0 ;
    salon = json["salon"] ??  '' ;
    user = json["user"] ??  '' ;
    duree = json["duree"] ??  30 ;
    prix = json["prix"] ??  0 ;
    remise = json["remise"] ??  0 ;
    comment = json['comment'] ?? '';
    team = json['team'] ?? false;
    teamInfo = Team.fromJson(json['teamInfo'] ?? {});
    location = json['location'] ?? '';
    userPhone = json['userPhone'] ?? '';
    prixFin = json["prixFin"] ?? 0 ;
  }


}