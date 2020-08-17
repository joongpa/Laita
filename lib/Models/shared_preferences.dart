import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper extends ChangeNotifier{
  SharedPreferencesHelper._();
  static final SharedPreferencesHelper instance = SharedPreferencesHelper._();

  SharedPreferences _pref;

  String _showAccuracyAsFraction = 'showAccuracyAsFraction';
  String _showCompletedCategoriesInLifetimeSummary = 'showCompletedCategoriesInLifetimeSummary';
  String _showCompletedCategoriesInGraph = 'showCompletedCategoriesInGraph';

  bool get showAccuracyAsFraction => _pref.get(_showAccuracyAsFraction);
  bool get showCompletedCategoriesInLifetimeSummary => _pref.get(_showCompletedCategoriesInLifetimeSummary) ?? true;
  bool get showCompletedCategoriesInGraph => _pref.get(_showCompletedCategoriesInGraph) ?? false;

  set showAccuracyAsFraction(bool value) {
    _pref.setBool(_showAccuracyAsFraction, value);
    notifyListeners();
  }

  set showCompletedCategoriesInLifetimeSummary(bool value) {
    _pref.setBool(_showCompletedCategoriesInLifetimeSummary, value);
    notifyListeners();
  }

  set showCompletedCategoriesInGraph(bool value) {
    _pref.setBool(_showCompletedCategoriesInGraph, value);
    notifyListeners();
  }

  init() async {
    _pref = await SharedPreferences.getInstance();
  }
}