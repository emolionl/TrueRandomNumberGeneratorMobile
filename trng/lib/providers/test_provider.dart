
import 'package:flutter/material.dart';

class TestProvider extends ChangeNotifier {
  String _name = 'my test';
  String _lastname = 'my lastname';
  int _counter = 0;
  String get name => _name;
  String get lastname => _lastname;
  int get counter => _counter;

  void changeName(String newName) {
    _name = newName;
    notifyListeners();
  }
  void changeLastname(String newName) {
    _lastname = newName;
    notifyListeners();
  }

  void upCounter() {
    _counter++;
    notifyListeners();
  }
  void downCounter() {
    _counter--;
    notifyListeners();
  }
}
