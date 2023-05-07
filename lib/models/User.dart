// ignore_for_file: file_names

import 'Team.dart';

class User {
  late String id;
  late String userName;
  late String phone;
  late String email;
  Team? team;
  bool haveTeam = false;

  User(this.id, this.userName,this.phone, this.email);

  User.fromJson(Map<String, dynamic> json) {
    userName = json['name'];
    phone = json['phone'];
    email = json['email'];
  }
}
