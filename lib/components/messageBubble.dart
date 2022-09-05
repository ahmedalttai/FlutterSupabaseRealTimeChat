import 'package:flutter/material.dart';

Widget messageBubble(
{
  required String chatContent,
required EdgeInsetsGeometry? margin,
Color? color,
Color? textColor
}
) {
  return Container(
    padding: EdgeInsets.all(10),
    margin: margin,
    width: 200,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      chatContent,
      style: TextStyle(fontSize: 16,color: textColor),
    ),
  );
}