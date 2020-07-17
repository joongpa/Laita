import 'package:shared_preferences/shared_preferences.dart';

import 'Map.dart';

class DataStorageHelper {
  DataStorageHelper._();
  static final _dsh = DataStorageHelper._();

  factory DataStorageHelper() {
    return _dsh;
  }

  SharedPreferences _pref;

  init() async {
    _pref = await SharedPreferences.getInstance();
  }

  double getHoursOfInput(InputType inputType) {
    return _pref.get('hours' + inputType.toString());
  }

  double getGoalOfInput(InputType inputType) {
    return _pref.get('goals' + inputType.toString());
  }

  void addInput(InputType inputType, double hours) {
    double totalHours = (_pref.get("hours" + inputType.toString()) ?? 0.0) + hours;
    _pref.setDouble("hours" + inputType.toString(), totalHours);
  }
}