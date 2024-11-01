import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import '../Services/location_services.dart';
import '../Widgets/SnaKeBar.dart';
import '../models/Hours.dart';
import '../models/Image.dart';
import '../models/Salon.dart';
import '../models/Service.dart';
import '../models/Team.dart';
import '../utils/wilaya.dart';
import 'package:geocoding/geocoding.dart';

class AuthProvider extends ChangeNotifier {

  Salon mySalon = Salon.fromJson({});

  UserCredential ? googleUserCredential;

  static TextEditingController _laWilaya = TextEditingController();
  TextEditingController get laWilaya => _laWilaya;

  TextEditingController _laCommune = TextEditingController();
  TextEditingController get laCommune => _laCommune;

  setlaWilaya(String wilayaa){
    String wilayaCode = wilaya.where((element) => element['name']!.contains(wilayaa)).first["code"]!;
    wilayaa = "$wilayaCode  $wilayaa";
    _laWilaya.text = wilayaa;
    _laCommune.clear();
    notifyListeners();
  }

  clearLaCommune(){
    _laCommune.clear();
    notifyListeners();
  }

  clearLaWilaya(){
    _laWilaya.clear();
    _laCommune.clear();
    notifyListeners();
  }

  setlaCommune(String commune){
    _laCommune.text = commune;
    notifyListeners();
  }

  void refresh(){notifyListeners();}








  // CREATE SALON

  Future<void> fillSalon(nom,bio,sex,phone) async {
    mySalon.sex = sex;
    mySalon.id = FirebaseAuth.instance.currentUser?.uid;
    mySalon.nom = nom;
    mySalon.description = bio;
    mySalon.phone = phone;
    mySalon.wilaya = _laWilaya.text.substring(4,_laWilaya.text.length);
    mySalon.commune = _laCommune.text;
    notifyListeners();
  }

  Future<void> createSalon() async {
    await FirebaseFirestore.instance.collection("salon").doc(FirebaseAuth.instance.currentUser?.uid).update({
      "sex": mySalon.sex,
      "nom": mySalon.nom,
      "description": mySalon.description,
      "wilaya": mySalon.wilaya,
      "commune": mySalon.commune,
      "best": false,
      "promo": false,
      "phone": mySalon.phone,
      "location":mySalon.location,
      "longitude":mySalon.longitude,
      "latitude":mySalon.latitude,
    });
    notifyListeners();
  }

  Future<void> createSalonSansLocation() async {
    await FirebaseFirestore.instance.collection("salon").doc(FirebaseAuth.instance.currentUser?.uid).update({
      "sex": mySalon.sex,
      "nom": mySalon.nom,
      "description": mySalon.description,
      "wilaya": mySalon.wilaya,
      "commune": mySalon.commune,
      "best": false,
      "promo": false,
      "phone": mySalon.phone,
      "location": "${mySalon.wilaya}, ${mySalon.commune}",
    });
    notifyListeners();
  }

  Future<void> updateSalon() async {
    await FirebaseFirestore.instance.collection("salon").doc(FirebaseAuth.instance.currentUser?.uid).update({
      "sex": mySalon.sex,
      "nom": mySalon.nom,
      "description": mySalon.description,
      "wilaya": mySalon.wilaya,
      "commune": mySalon.commune,
      "phone": mySalon.phone
    });
    notifyListeners();
  }










  // SALON INFO
  bool done = false;
  Future<void> getInfos(context,salonID) async {
    done = false;
    try{
      await FirebaseFirestore.instance.collection("salon").doc(salonID).get().then((snapshot){
        if(snapshot.data() != null){
          mySalon = Salon.fromJson(snapshot.data()!);
          mySalon.id = snapshot.id;
          setlaWilaya(mySalon.wilaya!);
          setlaCommune(mySalon.commune!);
          if(snapshot.get("latitude") != null && snapshot.get("longitude") != null ){
            setMarker(LatLng(snapshot.get("latitude"), snapshot.get("longitude")));
          }
        }
      });
      Timer(const Duration(seconds: 1),(){
        done =true;
        notifyListeners();
      });
    }
    catch(e){
      debugPrint(e.toString());
    }
    Timer(const Duration(seconds: 5),(){
      if(done == false) {
        done = true;
        final snackBar = snaKeBar('Internet Connection Problem',);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        notifyListeners();
      }
    });
  }













  // HOURS

  Future<void> getHours(salonID) async {
    try{
      await FirebaseFirestore.instance.collection("hours").doc(salonID).get()
      .then((snapshot) async {
        if(snapshot.exists){
          Hours hour = Hours.fromJson(snapshot.data()!);
          mySalon.hours = hour;
        }
        else{
          await createHours().then((value) => getHours(salonID));
        }
      });
    }
    catch(e){debugPrint(e.toString());}
    notifyListeners();
  }

  Future<void> updateHours() async {
    try{
      await FirebaseFirestore.instance.collection("hours").doc(FirebaseAuth.instance.currentUser?.uid).update({
        "dimanche": mySalon.hours?.jours["dimanche"],
        "lundi": mySalon.hours?.jours["lundi"],
        "mardi": mySalon.hours?.jours["mardi"],
        "mercredi": mySalon.hours?.jours["mercredi"],
        "jeudi": mySalon.hours?.jours["jeudi"],
        "vendredi": mySalon.hours?.jours["vendredi"],
        "samedi": mySalon.hours?.jours["samedi"],
      });
    }
    catch(e){debugPrint(e.toString());}
    try{
      await FirebaseFirestore.instance.collection("salonsSearch").doc(FirebaseAuth.instance.currentUser?.uid).update({
        "days.dimanche": mySalon.hours?.jours["dimanche"]["active"],
        "days.lundi": mySalon.hours?.jours["lundi"]["active"],
        "days.mardi": mySalon.hours?.jours["mardi"]["active"],
        "days.mercredi": mySalon.hours?.jours["mercredi"]["active"],
        "days.jeudi": mySalon.hours?.jours["jeudi"]["active"],
        "days.vendredi": mySalon.hours?.jours["vendredi"]["active"],
        "days.samedi": mySalon.hours?.jours["samedi"]["active"],
      });
    }
    catch(e){debugPrint(e.toString());}
    notifyListeners();
  }

  Future<void> createHours() async {
    try{
      await FirebaseFirestore.instance.collection("hours").doc(FirebaseAuth.instance.currentUser?.uid).set({
        "dimanche": {"active":false,"start":"00:00","fin":"00:00"},
        "lundi": {"active":false,"start":"00:00","fin":"00:00"},
        "mardi": {"active":false,"start":"00:00","fin":"00:00"},
        "mercredi": {"active":false,"start":"00:00","fin":"00:00"},
        "jeudi": {"active":false,"start":"00:00","fin":"00:00"},
        "vendredi": {"active":false,"start":"00:00","fin":"00:00"},
        "samedi": {"active":false,"start":"00:00","fin":"00:00"},
      });
    }
    catch(e){debugPrint(e.toString());}
    try{
      await FirebaseFirestore.instance.collection("salonsSearch").doc(FirebaseAuth.instance.currentUser?.uid).update({
        "days": {
          "dimanche": false,
          "lundi": false,
          "mardi": false,
          "mercredi": false,
          "jeudi": false,
          "vendredi": false,
          "samedi": false,
        },
      });
    }
    catch(e){debugPrint(e.toString());}
    notifyListeners();
  }

  changeDays(String day, bool value){
    mySalon.hours?.jours[day]["active"] = value;
    notifyListeners();
  }

  changeHours(String day,String start, String fin){
    mySalon.hours?.jours[day]["start"] = start;
    mySalon.hours?.jours[day]["fin"] = fin;
    notifyListeners();
  }











  // Services

  List<Service> listTempServices = [];

  Future<void> createSalonCategoriesAndServices() async {

    await FirebaseFirestore.instance.collection("salonsSearch").doc(FirebaseAuth.instance.currentUser?.uid).set({
      "category": mySalon.categories,
      "wilaya": mySalon.wilaya,
      "salonID": mySalon.id
    });

    for (var element in mySalon.service) {
      await FirebaseFirestore.instance.collection("services").add({
        "category": element.category,
        "categoryID": element.categoryID,
        "parDefault": false,
        "serviceID":element.serviceID,
        "service":element.service,
        "salonID": mySalon.id
      });
    }
    notifyListeners();
  }

  Future<void> updateSalonCategoriesAndServices() async {

    if(listTempServices.isNotEmpty){
      for (var srv in listTempServices) {
        if(mySalon.service.where((element) => element.id == srv.id).isEmpty){
          await FirebaseFirestore.instance.collection("services").doc(srv.id).delete();
          listTempServices.removeWhere((element) => element.id == srv.id);
        }
      }
    }

    if(mySalon.service.isNotEmpty){
      for (var element in mySalon.service) {
        if(listTempServices.isNotEmpty){
          if(listTempServices.where((srv) => srv.id == element.id).isEmpty){
            await FirebaseFirestore.instance.collection("services").add({
              "category": element.category,
              "categoryID": element.categoryID,
              "parDefault": false,
              "serviceID":element.serviceID,
              "service":element.service,
              "salonID": mySalon.id
            });
          }
        }
        if(listTempServices.isEmpty){
          await FirebaseFirestore.instance.collection("services").add({
            "category": element.category,
            "categoryID": element.categoryID,
            "parDefault": false,
            "serviceID":element.serviceID,
            "service":element.service,
            "salonID": mySalon.id
          });
        }
      }
      await FirebaseFirestore.instance.collection("salonsSearch").doc(FirebaseAuth.instance.currentUser?.uid).update({
        "category": mySalon.categories,
      });
    }
    else{
      await FirebaseFirestore.instance.collection("salonsSearch").doc(FirebaseAuth.instance.currentUser?.uid).update({
        "category": FieldValue.delete(),
      });
    }
    notifyListeners();
  }

  Future<void> updateServicesPrices(String id, int prix, int prixFin) async {

    mySalon.service.where((element) => element.id == id).first.prix = prix;
    mySalon.service.where((element) => element.id == id).first.prixFin = prixFin;
    notifyListeners();

    // 1 fois
    if(mySalon.prix == null){
      mySalon.prix = prix;
      await FirebaseFirestore.instance.collection("salonsSearch").doc(FirebaseAuth.instance.currentUser?.uid).update({"prix": prix,});
    }

    await FirebaseFirestore.instance.collection("services").doc(id).update({
      "prix": prix,
      "prixFin": prixFin,
    });

    int prixMin = mySalon.service.where((element) => element.prix! > 0).first.prix! ;
    for (var element in mySalon.service) {
      if(element.prix! <= prixMin && element.prix != 0){
        mySalon.prix = element.prix!;
        prixMin = element.prix!;
      }
    }
    await FirebaseFirestore.instance.collection("salonsSearch").doc(FirebaseAuth.instance.currentUser?.uid).update({
      "prix": prixMin,
    });
  }

  Future<void> getSalonCategoriesAndServices(salonID) async {
    mySalon.service.clear();
    mySalon.categories.clear();
    listTempServices.clear();
    try{
      await FirebaseFirestore.instance.collection("services").where("salonID", isEqualTo: salonID).get()
          .then((snapshot) async {
        if(snapshot.docs.isNotEmpty){
          for (var element in snapshot.docs) {
            Service service =  Service.fromJson(element.data());
            service.id = element.id;
            mySalon.service.add(service);
            if(!mySalon.categories.contains(service.category)){
              mySalon.categories.add(service.category!);
            }
          }
        }
      });
    }
    catch(e){debugPrint(e.toString());}
    listTempServices.addAll(mySalon.service);
    notifyListeners();
  }


  Future<void> deleteSalonCategoriesAndServices(id,categoryID) async {

    mySalon.service.removeWhere((element) => element.id == id);

    listTempServices.removeWhere((element) => element.id == id);

    if(mySalon.service.where((element) => element.category == categoryID).isEmpty){
      mySalon.categories.removeWhere((element) => element == categoryID);
    }
    await FirebaseFirestore.instance.collection("services").doc(id).delete();

    int prixMin = mySalon.service.where((element) => element.prix! > 0).first.prix! ;
    for (var element in mySalon.service) {
      if(element.prix! <= prixMin && element.prix != 0){
        mySalon.prix = element.prix!;
        prixMin = element.prix!;
      }
    }

    if(mySalon.categories.isEmpty){
      await FirebaseFirestore.instance.collection("salonsSearch").doc(FirebaseAuth.instance.currentUser?.uid).update({
        "category": FieldValue.delete(),
        "prix": FieldValue.delete(),
      });
    }
    else{
      if(mySalon.categories.contains(categoryID)){
        await FirebaseFirestore.instance.collection("salonsSearch").doc(FirebaseAuth.instance.currentUser?.uid).update({
          "prix": prixMin,
        });
      }
      else{
        await FirebaseFirestore.instance.collection("salonsSearch").doc(FirebaseAuth.instance.currentUser?.uid).update({
          "category": FieldValue.arrayRemove([categoryID]),
          "prix": prixMin,
        });
      }
    }

    await getSalonCategoriesAndServices(FirebaseAuth.instance.currentUser?.uid);

    notifyListeners();
  }



  // REMISE
  Future<void> updateRemise(int remise) async {
    await FirebaseFirestore.instance.collection("salon").doc(FirebaseAuth.instance.currentUser?.uid).update({"remise": remise,"promo": true}).then((value){
      mySalon.remise = remise;
      mySalon.promo = true;
    });
    notifyListeners();
  }

  Future<void> deleteRemise() async {
    await FirebaseFirestore.instance.collection("salon").doc(FirebaseAuth.instance.currentUser?.uid).update({"remise": FieldValue.delete(),"promo": false }).then((value){
      mySalon.remise = 0 ;
      mySalon.promo = false;
    });
    notifyListeners();
  }









  // SALON EXPERTS
  Future<void> getExperts(context,salonID) async {
    mySalon.teams.clear();
    try{
      await FirebaseFirestore.instance.collection("team").where("salonID",isEqualTo: salonID).get().then((snapshot){
        if(snapshot.docs.isNotEmpty){
          for (var element in snapshot.docs) {
            Team team = Team.fromJson(element.data());
            team.id = element.id;
            mySalon.teams.add(team);
          }
        }
      });
    }
    catch(e){
      final snackBar = snaKeBar(e.toString(),);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  Future<void> ajouterExperts(Team newTeam) async {
    await FirebaseFirestore.instance.collection("team").add(newTeam.toJson()).then((value) async {
      if(mySalon.teams.isEmpty){
        mySalon.team = true;
        await FirebaseFirestore.instance.collection("salon").doc(FirebaseAuth.instance.currentUser?.uid).update({"team":true});
      }
      newTeam.id = value.id;
      mySalon.teams.add(newTeam);
    });
    notifyListeners();
  }

  Future<void> activeExpert(id,active) async {
    await FirebaseFirestore.instance.collection("team").doc(id).update({"active": active});
    mySalon.teams.where((element) => element.id == id).first.active = active;
    if(mySalon.teams.where((element) => element.active == true).isEmpty){
      mySalon.team = false;
      await FirebaseFirestore.instance.collection("salon").doc(FirebaseAuth.instance.currentUser?.uid).update({"team":false});
    }
    if(mySalon.teams.where((element) => element.active == true).isNotEmpty){
      mySalon.team = true;
      await FirebaseFirestore.instance.collection("salon").doc(FirebaseAuth.instance.currentUser?.uid).update({"team":true});
    }
    notifyListeners();
  }

  Future<void> deleteExpert(id) async {
    await FirebaseFirestore.instance.collection("team").doc(id).delete();
    mySalon.teams.removeWhere((element) => element.id == id);
    if(mySalon.teams.isEmpty){
      mySalon.team = false;
      await FirebaseFirestore.instance.collection("salon").doc(FirebaseAuth.instance.currentUser?.uid).update({"team":false});
    }
    notifyListeners();
  }

  Future<void> updateExpert(Team team) async {
    await FirebaseFirestore.instance.collection("team").doc(team.id).update(team.toJson());
    mySalon.teams.removeWhere((element) => element.id == team.id);
    mySalon.teams.add(team);
    notifyListeners();
  }








  // PHOTOS

  List<Pic> images = [];
  List<XFile> imagesFiles = [];


  Future<void> getSalonImages() async {
    images.clear();
    imagesFiles.clear();
    try{
      ListResult listResult = await FirebaseStorage.instance.ref().child('salons/${FirebaseAuth.instance.currentUser?.uid}').listAll();
      if(listResult.items.isNotEmpty){
        for (var element in listResult.items){
          try{
            String path = await FirebaseStorage.instance.ref().child(element.fullPath).getDownloadURL();
            String name = FirebaseStorage.instance.ref().child(element.fullPath).name;
            images.add(Pic(name, path));
            notifyListeners();
          }
          catch(ee){debugPrint("====== $ee =======");}
        }
      }
      else{await deleteLien();}
    }
    catch(e){debugPrint(e.toString());}
    notifyListeners();
  }

  Future<void> uploadSalonImages() async {
    if(images.isEmpty && mySalon.photo == ''){changeMainPhoto(imagesFiles.first.path);}
    await Future.wait(imagesFiles.map((image) => uploadFile(image)));
    notifyListeners();
  }

  Future<Directory> getTemporaryDirectory() async {
    return Directory.systemTemp;
  }

  Future<String> uploadFile(XFile img) async {
    final storageReference = FirebaseStorage.instance.ref().child('salons/${FirebaseAuth.instance.currentUser?.uid}/${img.name}');
    final dir = await getTemporaryDirectory();
    File? result = await FlutterImageCompress.compressAndGetFile(
      img.path, '${dir.absolute.path}/${img.name}.jpg',
      quality: 70,
    );
    UploadTask uploadTask = storageReference.putFile(File(result!.absolute.path));
    await uploadTask.whenComplete(()async{if(img.path == mySalon.photo){ await storageReference.getDownloadURL().then((value) async => await updateMainPicture(value));}});
    notifyListeners();
    return await storageReference.getDownloadURL();
  }

  addTempsImages(XFile file){
    imagesFiles.add(file);
    notifyListeners();
  }

  removeTempsImages(String file){
    imagesFiles.removeWhere((element) => element.path == file);
    notifyListeners();
  }

  changeMainPhoto(String path){mySalon.photo = path;notifyListeners();}

  Future<void> deleteImage(String name) async {
    try{
      final desertRef = FirebaseStorage.instance.ref().child('salons/${FirebaseAuth.instance.currentUser?.uid}/$name');
      if(mySalon.photo == await desertRef.getDownloadURL()){await deleteLien();}
      await desertRef.delete();
      images.removeWhere((element) => element.name == name);
    }
    catch(ee){debugPrint("====== $ee =======");}
    notifyListeners();
  }

  Future<void> updateMainPicture(String path) async {
    try{
      await FirebaseFirestore.instance.collection("salon").doc(FirebaseAuth.instance.currentUser?.uid).update({
        "lien": path,
      });
      mySalon.photo = path;
    }
    catch(e){debugPrint(e.toString());}
    notifyListeners();
  }

  Future<void> deleteLien() async {
    mySalon.photo = '';
    try{
      await FirebaseFirestore.instance.collection("salon").doc(FirebaseAuth.instance.currentUser?.uid).update({
        "lien": FieldValue.delete(),
      });
    }
    catch(e){debugPrint(e.toString());}
    notifyListeners();
  }















  // MAPS
  Set<Marker> markers = {};
  CameraPosition myLocation = const CameraPosition(target: LatLng(28.26566, 3.01618), zoom: 20,);

  changeLocation(nowLocation){
    myLocation = CameraPosition(target: LatLng(nowLocation.latitude!, nowLocation.longitude!), zoom: 14.5,);
    notifyListeners();
  }

  Future<void> setMarker(LatLng currentLocation) async {
    markers.clear();
    List<Placemark> placemarks = await placemarkFromCoordinates(currentLocation.latitude, currentLocation.longitude);
    BitmapDescriptor markIcon = BitmapDescriptor.defaultMarkerWithHue(20);
    Marker newMarker = Marker(
      markerId: const MarkerId("1"),
      position: currentLocation,
      infoWindow: InfoWindow(
        title: "${placemarks.first.street}, ${placemarks.first.administrativeArea}, ${placemarks.first.country}",
        snippet: "Lat: ${currentLocation.latitude}, Long: ${currentLocation.longitude}"
      ),
      icon: markIcon,
    );
    markers.add(newMarker);
    mySalon.location = "${placemarks.first.street}, ${placemarks.first.administrativeArea}, ${placemarks.first.country} ";
    mySalon.latitude = currentLocation.latitude;
    mySalon.longitude = currentLocation.longitude;
    notifyListeners();
  }

  Future<void> getMyLocation(context) async {
    try{
      LocationData nowLocation = await LocationService().getLocation();
      changeLocation(nowLocation);
    }
    catch(e){
      GFToast.showToast(e.toString(), context,backgroundColor: Colors.black,toastPosition: GFToastPosition.BOTTOM,toastDuration: 4);
    }
  }

  Future<void> updateSalonLocation(context) async {
    try{
      await FirebaseFirestore.instance.collection("salon").doc(FirebaseAuth.instance.currentUser?.uid).update({
        "location":mySalon.location,
        "longitude":mySalon.longitude,
        "latitude":mySalon.latitude,
      });
    }
    catch(e){
      GFToast.showToast(e.toString(), context,backgroundColor: Colors.black,toastPosition: GFToastPosition.BOTTOM,toastDuration: 4);
    }
  }






  // LOG OUT

  Future signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    googleUserCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    notifyListeners();

    if(googleUserCredential != null)return googleUserCredential;
  }

  Future<void> googleLogOut() async {
    FirebaseAuth.instance.signOut();
    await GoogleSignIn().disconnect();
    await GoogleSignIn().signOut();
    notifyListeners();
  }

  Future<void> logOut() async {
    FirebaseAuth.instance.signOut();
    notifyListeners();
  }

}