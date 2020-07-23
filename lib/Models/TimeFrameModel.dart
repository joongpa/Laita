

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

class TimeFrameModel {
  static final TimeFrameModel _model = TimeFrameModel._();
  TimeSpan _selectedTimeSpan = TimeSpan.Week;
  DateTime realMonth;
  Map<TimeSpan, DateTime> _displayDates = Map<TimeSpan, DateTime>();
  BehaviorSubject<List<DateTime>> _timeFrame;
  Stream get timeFrameStream$ => _timeFrame.stream;

  set selectedTimeSpan(TimeSpan timeSpan) {
    _selectedTimeSpan = timeSpan;
    _emitStream();
  }

  TimeSpan get selectedTimeSpan => _selectedTimeSpan;

  TimeFrameModel._() {
    TimeSpan.values.forEach((timeSpan) {
      final Map<TimeSpan, DateTime> map = {timeSpan : getNewStartingDate(false, DateTime.now(), timeSpan: timeSpan)};
      _displayDates.addAll(map);
    });
    _timeFrame = BehaviorSubject.seeded([_displayDates[_selectedTimeSpan], daysAgo(-_selectedTimeSpan.value, _displayDates[_selectedTimeSpan])]);
  }

  factory TimeFrameModel() {
    return _model;
  }

  void shiftTimeFramePast() {
    updateTimeFrame(false);
  }

  void shiftTimeFrameFuture() {
    updateTimeFrame(true);
  }

  void updateTimeFrame(bool isForward) {
    _displayDates[_selectedTimeSpan] = getNewStartingDate(
        isForward, _displayDates[_selectedTimeSpan]);
    _emitStream();
  }

  void _emitStream() {
    _timeFrame.add([_displayDates[_selectedTimeSpan], daysAgo(-_selectedTimeSpan.value, _displayDates[_selectedTimeSpan])]);
  }

  DateTime _getNearestSunday(
      {@required bool isForward, @required DateTime dateTime, bool includeToday}) {
    includeToday ??= false;
    for (int i = includeToday ? 0 : 1; i <= 7; i++) {
      final testDay = daysAgo(isForward ? -i : i, dateTime);
      if (testDay.weekday == DateTime.sunday) return testDay;
    }
    return DateTime.now();
  }

  DateTime _monthsAgo(int months, DateTime dateTime, {bool monthStartsOnSunday = false}) {
    if (dateTime.day != 1 && months > 0 && !monthStartsOnSunday) months = 0;

    realMonth = monthsAgo(months, realMonth);

    if(monthStartsOnSunday) {
      return _getNearestSunday(isForward: false,
          dateTime: realMonth, includeToday: true);
    }
    else return realMonth;
  }

  DateTime _halfYearsAgo(int years, DateTime dateTime) {
    for (int i = 1; i <= 6; i++) {
      final testDay = monthsAgo(years * 6, dateTime);
      if (testDay.month == DateTime.january || testDay.month == DateTime.july)
        return testDay;
    }
    return DateTime.now();
  }

  // ignore: missing_return
  DateTime getNewStartingDate(bool forward, DateTime dateTime, {TimeSpan timeSpan}) {
    timeSpan ??= _selectedTimeSpan;

    switch (timeSpan) {
      case TimeSpan.HalfYear:
        return _halfYearsAgo(forward ? -1 : 1, dateTime);
        break;
      case TimeSpan.Month:
        return _monthsAgo(forward ? -1 : 1, dateTime, monthStartsOnSunday: true);
        break;
      case TimeSpan.Week:
        return _getNearestSunday(isForward: forward, dateTime: dateTime);
        break;
    }
  }


}