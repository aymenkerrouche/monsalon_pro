import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Theme/colors.dart';

String formatPrice(int priceToFormat) {
  final total = NumberFormat('#,###');
  return total.format(priceToFormat);
}

extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');
}

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
      gapPadding: 6);
}

OutlineInputBorder inputBorder() {
  return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: primary, width: 1.5),
      gapPadding: 6);
}


DateFormat dateFormat = DateFormat("dd-MM-yyyy HH:mm");


// DAYS
const Map<int, String> weekdayName = {1: "lundi", 2: "mardi", 3: "mercredi", 4: "jeudi", 5: "vendredi", 6: "samedi", 7: "dimanche"};

const Map<int, String> lesMois = { 1:'Janvier',2: 'Février',3: 'Mars', 4:'Avril', 5:'Mai', 6:'Juin', 7:'Juillet', 8:'Août', 9:'Septembre', 10:'Octobre', 11:'Novembre', 12:'Décembre'};