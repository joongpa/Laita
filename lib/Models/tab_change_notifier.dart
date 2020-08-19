
import 'package:flutter/cupertino.dart';

class TabChangeNotifier extends ChangeNotifier {
  TabChangeNotifier._();
  static final instance = TabChangeNotifier._();

  int _index;

  int get index => _index;

  set index(value) {
    _index = value;
    notifyListeners();
  }
}