// ignore_for_file: file_names

import 'package:monsalon_pro/models/Service.dart';
import 'Category.dart';
import 'Hours.dart';
import 'Team.dart';

class Salon {
  String? id;
  String? nom;
  String? wilaya;
  String? photo;
  String? sex;
  bool? promo;
  double? rate;
  double? latitude;
  double? longitude;
  String? location;
  String? commune;
  String? description;
  String? phone;
  Hours? hours;
  List<String> categories = [];
  List<Service> service = [];
  bool team = false;
  List<Team> teams = [];
  int? prix;
  int? remise;

  Salon(this.nom, this.wilaya,this.prix, this.remise,this.hours,this.teams,this.promo,this.rate,this.photo, this.id, this.description, this.team,this.latitude, this.longitude,this.location,this.phone,this.commune,this.categories, this.service);

  Salon.fromJson(Map<String, dynamic> json){
    id= json['id'] ?? '';
    nom = json['nom'] ?? '';
    wilaya = json['wilaya'] ?? '';
    promo = json['promo'] ?? false;
    photo = json['lien'] ?? '';
    description  = json['description'] ?? '';
    latitude = json['latitude'] ?? 0;
    longitude = json['longitude'] ?? 0;
    location  = json['location'] ?? '';
    phone = json['phone'] ?? '';
    commune = json['commune'] ?? '';
    rate = json['rate'] == null ? 5.0 : json['rate'].toDouble();
    team = json['team'] ??  false;
    remise = json['remise'] ?? 0;
    sex = json["sex"] ?? '';
  }
}