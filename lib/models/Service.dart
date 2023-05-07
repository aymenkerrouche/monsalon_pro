class Service {
  String? id;
  String? service;
  String? serviceID;
  String? category;
  String? categoryID;
  String? salonID;
  int? prix;
  int? prixFin;
  bool? parDefault;

  Service(this.id,this.service,this.category,this.categoryID,this.salonID);

  Service.fromJson(Map<String, dynamic> json){
    category = json['category'] ?? 'Autre';
    service = json['service'] ?? '';
    categoryID= json['categoryID'] ?? '';
    salonID= json['salonID'] ?? '';
    serviceID= json['serviceID'] ?? '';
    prix= json['prix'] ?? 0;
    prixFin= json['prixFin'] ?? 0;
    parDefault = json['parDefault'] ?? false;
  }

  Map<String, dynamic> toJson() => {
    "serviceID": id,
    "service": service,
    "prix" : prix,
    "prixFin" : prixFin
  };

}