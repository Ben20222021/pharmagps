import 'package:flutter/material.dart';

double getPhoneHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double getPhoneWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}
