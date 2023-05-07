import 'package:flutter/material.dart';

SnackBar snaKeBar(String text){
  return SnackBar(
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 3),
    content: Text(text,
      style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 14),
    ),
  );
}

SnackBar snaKeBarIcon(String text, IconData icon){
  return SnackBar(
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 3),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text,
          style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 14),
        ),
        Icon(icon,color: Colors.white,),
      ],
    ),
  );
}

SnackBar snaKeBarDone(String text){
  return SnackBar(
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.teal.shade700,
    content: Text(text,
      style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 14),
    ),
  );
}