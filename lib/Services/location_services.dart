// ignore_for_file: unnecessary_new, no_leading_underscores_for_local_identifiers

import 'package:location/location.dart';

class LocationService {
  Future<LocationData> getLocation() async {
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        throw Exception();
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        throw Exception("donnez-nous l'autorisation de localisation");
      }
    }

    _locationData = await location.getLocation();
    return _locationData;
  }
}