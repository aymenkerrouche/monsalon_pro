// ignore_for_file: file_names, must_be_immutable

import 'package:flutter/material.dart';
import '../theme/colors.dart';


Widget buildPhoneNumberFormField(phoneController,label, hint) {
  return Container(
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),color: Colors.white,),
    child: TextFormField(
      keyboardType: TextInputType.phone,
      controller: phoneController,
      cursorColor: primary,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(fontWeight: FontWeight.w600,color: Colors.black45),
        labelStyle: const TextStyle(color: primary),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: const Icon(
          Icons.phone_rounded,
          color: primary,
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primary, width: 1.5),
            gapPadding: 6),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: clr3.withOpacity(.5), width: 1.5),
            gapPadding: 6),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
      ),
    ),
  );
}


class TextInfomation extends StatelessWidget {
  TextInfomation({Key? key, required this.textController, this.hint, this.label,this.icon, this.textType = TextInputType.number, this.readOnly = false, this.maxLine= 1}) : super(key: key);
  TextEditingController textController;
  String? label ;
  String? hint ;
  IconData? icon;
  TextInputType? textType;
  bool readOnly;
  int maxLine;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),color: Colors.white,),
      child: TextFormField(
        keyboardType: textType,
        controller: textController,
        cursorColor: primary,
        textCapitalization: TextCapitalization.sentences,
        readOnly: readOnly,
        maxLines: maxLine,
        style: const TextStyle(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: primary),
          hintText: hint,
          hintStyle: const TextStyle(fontWeight: FontWeight.w600,color: Colors.black45),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: Icon(
            icon,
            color: primary,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: primary, width: 1),
              gapPadding: 6),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
        ),
      ),
    );
  }
}
