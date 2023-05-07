// ignore_for_file: file_names

class Hours {
  String? id;
  Map<String, dynamic> jours = {};
  Hours(this.id, this.jours,);

  Hours.fromJson(Map<String, dynamic> json){
    id= json['salonID'] ?? '';
    jours = {
      "dimanche": json["dimanche"],
      "lundi": json["lundi"],
      "mardi": json["mardi"],
      "mercredi": json["mercredi"],
      "jeudi": json["jeudi"],
      "vendredi": json["vendredi"],
      "samedi": json["samedi"],
    };
  }
}