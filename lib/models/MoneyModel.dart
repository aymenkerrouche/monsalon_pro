
import 'package:firebase_auth/firebase_auth.dart';

class Money {

  String? id;

  int? prixTotal;
  int? prixFinTotal;

  int? prixCeMois;
  int? prixFinCeMoins;

  int? etatGeneral;
  int? etatCeMois;
  int? rdv;

  int? commission;
  int? fraisDeService;
  double? commissionTotal;

  Money(this.id,this.prixTotal, this.commission, this.fraisDeService, this.prixFinTotal, this.prixCeMois, this.prixFinCeMoins, this.etatGeneral, this.rdv , this.etatCeMois);

  Money.fromJson(Map<String, dynamic> json){

    id = FirebaseAuth.instance.currentUser?.uid;

    prixTotal = json['prixTotal'] ?? 0 ;
    prixFinTotal = json['prixFinTotal'] ?? 0 ;
    etatGeneral = json['etat'] ?? 0 ;

    try{
      prixCeMois = json["prix${DateTime.now().year}"]["${DateTime.now().month}"] ?? 0 ;
    }
    catch(e){
      prixCeMois = 0 ;
    }

    try{
      prixFinCeMoins = json["prixFin${DateTime.now().year}"]["${DateTime.now().month}"] ?? 0 ;
    }
    catch(e){
      prixFinCeMoins = 0 ;
    }

    try{
      rdv = json["rdv${DateTime.now().year}"]["${DateTime.now().month}done"] ?? 0 ;
    }
    catch(e) {
      rdv = 0;
    }

    try{
      etatCeMois = json["etat${DateTime.now().year}"]["${DateTime.now().month}"] ?? 0 ;
    }
    catch(e){
      etatCeMois = 0 ;
    }

  }
}