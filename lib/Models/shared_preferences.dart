import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SharedPreferencesHelper extends ChangeNotifier{
  SharedPreferencesHelper._();
  static final SharedPreferencesHelper instance = SharedPreferencesHelper._();

  SharedPreferences _pref;

  String _showAccuracyAsFraction = 'showAccuracyAsFraction';
  String _showCompletedCategoriesInLifetimeSummary = 'showCompletedCategoriesInLifetimeSummary';
  String _showCompletedCategoriesInGraph = 'showCompletedCategoriesInGraph';
  //String _selectedSortValue = 'selectedSortValue';

  bool get showAccuracyAsFraction => _pref.get(_showAccuracyAsFraction) ?? false;
  bool get showCompletedCategoriesInLifetimeSummary => _pref.get(_showCompletedCategoriesInLifetimeSummary) ?? true;
  bool get showCompletedCategoriesInGraph => _pref.get(_showCompletedCategoriesInGraph) ?? false;

//  SortType get selectedSortValue {
//    String sortType = _pref.get(_selectedSortValue);
//    try {
//      return SortType.values.where((sort) => sort.name == sortType).first;
//    } catch (e) {
//      return null;
//    }
//  }

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

//  set selectedSortType(SortType sortType) {
//    _pref.setString(_selectedSortValue, sortType.name);
//  }

  init() async {
    _pref = await SharedPreferences.getInstance();
  }
}