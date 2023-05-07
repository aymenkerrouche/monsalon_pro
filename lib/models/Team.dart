// ignore_for_file: file_names

class Team {
  String? salonID;
  String? userID;
  String? name;
  bool? accept;
  bool? create;
  bool? active;
  String? id;

  Team(this.name, this.active ,this.salonID, this.userID, this.create, this.accept, this.id);

  Team.fromJson(Map<String, dynamic> json){
    salonID= json['salonID'] ?? '';
    userID= json['userID'] ?? '';
    name= json['name'] ?? '';
    accept= json['accept'] ?? false;
    create= json['create'] ?? false;
    active = json["active"] ?? false;
  }

  Map<String, dynamic> toJson() => {
    "salonID": salonID,
    "userID": userID,
    "name" : name,
    "accept" : accept,
    "create": create,
    "active": active
  };
}