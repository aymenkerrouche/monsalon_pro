
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../models/Category.dart';
import '../models/Service.dart';


class CategoriesProvider extends ChangeNotifier {

  List<Category> _categories = [];
  List<Category> get categories => _categories;
  bool done = false;

  Future getCategories() async {
    _categories.clear();
    done = false;
    await FirebaseFirestore.instance.collection("categories").orderBy('category').get().then((snapshot){
       for (var element in snapshot.docs) {
          Category data = Category.fromJson(element.data());
          data.id = element.id;
          _categories.add(data);
       }
    })
    .catchError((e){
      debugPrint(e.toString());
      done = false;
    });
    notifyListeners();
  }

  Future getServices() async {
    await FirebaseFirestore.instance.collection("services").where("parDefault", isEqualTo: true ).get().then((snapshot){
      for (var element in snapshot.docs) {
        Service data = Service.fromJson(element.data());
        data.id = element.id;
        data.serviceID = element.id;
        data.categoryID = element["category_id"];
        _categories.where((e) => e.category == data.category).first.servicesParDefault.add(data);
      }
    });
    notifyListeners();
  }
}