

import 'package:flutter/cupertino.dart';
import 'package:miatracker/Map.dart';
import 'package:rxdart/rxdart.dart';

enum TimeSpan{
  HalfYear, Month, Week
}
extension TimeSpanExtension on TimeSpan {
  int get value => const {
    TimeSpan.HalfYear: 183,
    TimeSpan.Month: 35,
    TimeSpan.Week: 7,
  }[this];

  String get name => const {
    TimeSpan.HalfYear: 'Year',
    TimeSpan.Month: 'Month',
    TimeSpan.Week: 'Week',
  }[this];
}

class TimeFrameModel extends ChangeNotifier{
  static final TimeFrameModel _model = TimeFrameModel._();
  TimeSpan _selectedTimeSpan = TimeSpan.Week;
  Map<TimeSpan, DateTime> _displayDates = Map<TimeSpan, DateTime>();

  set selectedTimeSpan(TimeSpan timeSpan) {
    _selectedTimeSpan = timeSpan;
    notifyListeners();
  }

  TimeSpan get selectedTimeSpan => _selectedTimeSpan;
  List<DateTime> get dateStartEndTimes => [
    daysAgo(_selectedTimeSpan.value, _displayDates[_selectedTimeSpan]),
    _displayDates[_selectedTimeSpan]
  ];

  TimeFrameModel._() {
    refresh();
  }

  factory TimeFrameModel() {
    return _model;
  }

  void refresh() {
    TimeSpan.values.forEach((timeSpan) {
      final Map<TimeSpan, DateTime> map = {timeSpan : daysAgo(-1, DateTime.now())};
      _displayDates.addAll(map);
    });
  }

  void shiftTimeFramePast() {
    _displayDates[_selectedTimeSpan] = getNewEndDate(
        false, _displayDates[_selectedTimeSpan]);
    notifyListeners();
  }

  void shiftTimeFrameFuture() {
    _displayDates[_selectedTimeSpan] = getNewEndDate(
        true, _displayDates[_selectedTimeSpan]);
    notifyListeners();
  }
//
//  DateTime _getNearestSunday(
//      {@required bool isForward, @required DateTime dateTime, bool includeToday}) {
//    includeToday ??= false;
//    for (int i = includeToday ? 0 : 1; i <= 7; i++) {
//      final testDay = daysAgo(isForward ? -i : i, dateTime);
//      if (testDay.weekday == DateTime.sunday) return testDay;
//    }
//    return DateTime.now();
//  }
//
//  DateTime _monthsAgo(int months, DateTime dateTime, {bool monthStartsOnSunday = false}) {
//    if (dateTime.day != 1 && months > 0 && !monthStartsOnSunday) months = 0;
//
//    realMonth = monthsAgo(months, realMonth);
//
//    if(monthStartsOnSunday) {
//      return _getNearestSunday(isForward: false,
//          dateTime: realMonth, includeToday: true);
//    }
//    else return realMonth;
//  }
//
//  DateTime _halfYearsAgo(int years, DateTime dateTime) {
//    for (int i = 1; i <= 6; i++) {
//      final testDay = monthsAgo(years * i, dateTime, true);
//      if (testDay.month == DateTime.january || testDay.month == DateTime.july)
//        return testDay;
//    }
//    return DateTime.now();
//  }

  // ignore: missing_return
  DateTime getNewEndDate(bool forward, DateTime dateTime, {TimeSpan timeSpan}) {
    timeSpan ??= _selectedTimeSpan;

    switch (timeSpan) {
      case TimeSpan.HalfYear:
        return daysAgo(forward ? -183 : 183, dateTime);
        //return _halfYearsAgo(forward ? -1 : 1, dateTime);
        break;
      case TimeSpan.Month:
        return daysAgo(forward ? -35 : 35, dateTime);
        //return _monthsAgo(forward ? -1 : 1, dateTime, monthStartsOnSunday: true);
        break;
      case TimeSpan.Week:
        return daysAgo(forward ? -7 : 7, dateTime);
        //return _getNearestSunday(isForward: forward, dateTime: dateTime);
        break;
    }
  }
}