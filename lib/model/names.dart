import 'package:flutter/material.dart';

class Names extends ChangeNotifier {
  List<String> names = [];
  void ajouter(String s) {
    names.add(s);
    notifyListeners();
  }

  void vider() {
    names = [];
    notifyListeners();
  }
}
