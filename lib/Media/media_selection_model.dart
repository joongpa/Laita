

import 'package:flutter/cupertino.dart';
import 'package:miatracker/Map.dart';
import 'package:miatracker/Models/user.dart';

class MediaSelectionModel extends ChangeNotifier {

  MediaSelectionModel._();
  static final instance = MediaSelectionModel._();

  Map<String,SortType> _selectedSortTypes = {
    'In Progress': SortType.lastUpdated,
    'Complete': SortType.lastUpdated,
    'Dropped': SortType.lastUpdated,
  };
  Category _selectedCategory;

  Map<String, SortType> get selectedSortTypes => _selectedSortTypes;
  Category get selectedCategory => _selectedCategory;

  void setSelectedSortType(SortType sortType, String watchStatus) {
    _selectedSortTypes[watchStatus] = sortType;
    notifyListeners();
  }

  set selectedCategory(Category category) {
    _selectedCategory = category;
    notifyListeners();
  }
}