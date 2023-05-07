import 'package:monsalon_pro/models/Service.dart';

class Category {
  String? id;
  String? category;
  String photo = '';
  List<Service> servicesParDefault = [];

  Category(this.id,this.category, this.photo);

  Category.fromJson(Map<String, dynamic> json){
    category = json['category'] ?? '';
  }
}