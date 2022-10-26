import 'package:flutter/material.dart';

class NewUICnst {
  static const String fontFamily = "Roboto";

  static const double rowHeight = 50.0;
  static const double borderRadius = 9.0;

  static const TextStyle buttonTextStyle = TextStyle(
      fontSize: 24, height: NewUICnst.inputHeight, fontWeight: FontWeight.w300);

  static const TextStyle fieldHintStyle =
      TextStyle(fontWeight: FontWeight.w300, color: Colors.grey, fontSize: 18);

  static const TextStyle titleStyle =
      TextStyle(fontSize: 28, fontWeight: FontWeight.w500);

  static const double inputHeight = 1;

  static const Color focuseBorderColor = Colors.black;
  static Color enabledBorderColor = Colors.grey[500];
  static Color disabledBorderColor = Colors.grey[800];
  static const Color errorBorderColor = Colors.red;

  static const Color radicalRed = Color(0xffff3366);
  static const Color independenceBlue = Color(0xff495867);
  static const Color uclaBlue = Color(0xff577399);
  static const Color paleAgua = Color(0xffbdd5ea);
  static const Color ghostWhite = Color(0xfff7f7ff);
}

class KeysCnst {
  static const String savedDays = 'savedDays';
  static const String bgTask = 'bgTask';
  static const String remoteWork = 'remoteWork';
  static const String workStartTime = "workStartTime";
  static const String workEndTime = "workEndTime";
  static const String breakStartTime = "breakStartTime";
  static const String breakEndTime = "breakEndTime";
}
