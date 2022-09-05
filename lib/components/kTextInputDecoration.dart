import 'package:flutter/material.dart';

const kTextInputDecoration = InputDecoration(
  labelStyle: TextStyle(
    color: Colors.deepPurple,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(color: Colors.grey,width: 1.5),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red,width: 1.5),
    borderRadius: BorderRadius.all(Radius.circular(10)),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red,width: 1.5),
    borderRadius: BorderRadius.all(Radius.circular(10)),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red,width: 1.5),
    borderRadius: BorderRadius.all(Radius.circular(10)),
  )
);