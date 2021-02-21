import 'package:flutter/material.dart';

BoxDecoration customDecoration() {
  return BoxDecoration(
      border: Border.all(), borderRadius: BorderRadius.circular(12));
}

InputDecoration registerInputDecoration({@required String hintText}) {
  return InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 10),
      hintStyle: TextStyle(fontSize: 16),
      hintText: hintText,
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent, width: 2)),
      enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      errorBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 2, color: Colors.red)),
      errorStyle: TextStyle(color: Colors.redAccent));
}
