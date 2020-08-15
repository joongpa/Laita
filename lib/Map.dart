import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'Models/user.dart';

String getMonth(int month) {
  Map<int, String> months = {
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'May',
    6: 'Jun',
    7: 'Jul',
    8: 'Aug',
    9: 'Sep',
    10: 'Oct',
    11: 'Nov',
    12: 'Dec',
  };

  return months[month];
}

String getDay(int weekday) {
  Map<int, String> days = {
    1: 'Mon',
    2: 'Tue',
    3: 'Wed',
    4: 'Thurs',
    5: 'Fri',
    6: 'Sat',
    7: 'Sun',
  };
  return days[weekday];
}

String getDate(DateTime date,
    {bool showDay = true, bool showYear = true, bool showMonth = true}) {
  String year = '';
  year = (showYear) ? ', ${date.year}' : '';
  if ((showMonth) && (showYear) && !(showDay)) year = date.year.toString();
  int month = date.month;
  String day = (showDay) ? '${date.day}' : '';

  return '${(showMonth ?? true) ? getMonth(month) + ' ' : ''}$day$year'.trim();
}

int daysBetween(DateTime d1, DateTime d2) {
  d1 = DateTime.utc(d1.year, d1.month, d1.day);
  d2 = DateTime.utc(d2.year, d2.month, d2.day);
  return d1.difference(d2).inDays.abs();
}

bool sameDay(DateTime date, DateTime date2) {
  return (date.year == date2.year) &&
      (date.month == date2.month) &&
      (date.day == date2.day);
}

bool sameMonth(DateTime date, DateTime date2) {
  return (date.year == date2.year) && (date.month == date2.month);
}

DateTime daysAgo(int days, [DateTime dateTime]) {
  dateTime = dateTime ?? DateTime.now();
  return DateTime(dateTime.year, dateTime.month, dateTime.day - days);
}

DateTime monthsAgo(int months, [DateTime dateTime, bool dayIndependent = false]) {
  dateTime = dateTime ?? DateTime.now();
  if (dateTime.day != 1 && months > 0 && !dayIndependent) months = 0;
  return DateTime(dateTime.year, dateTime.month - months, 1);
}

class UsefulShit {
  UsefulShit._();

  static final singleDecimalFormat = NumberFormat("0.0");
  static final doubleDecimalFormat = NumberFormat("0.00");
  static final leadingZeroFormat = NumberFormat("00");
}

String convertToStatsDisplay(double time, [bool isTimeBased = true]) {
  if(time < 0) return (isTimeBased) ? '0:00' : '0.0';
  int hours = time.floor();
  int minutes = ((time % 1) * 60).round();

  return (isTimeBased) ? '$hours:${NumberFormat("00").format(minutes)}' : UsefulShit.singleDecimalFormat.format(time);

}

String convertToDisplay(double time, [bool isTimeBased = true]) {
  time = (time * 100).round().toDouble()/100;
  if(time < 0) return (isTimeBased) ? '0:00' : '0';
  int hours = time.floor();
  int minutes = ((time % 1) * 60).round();

  return (isTimeBased) ? '$hours:${NumberFormat("00").format(minutes)}' : time.round().toString();

}

Category categoryFromName(String name, List<Category> categories) {
  return categories.toSet().lookup(Category(name: name));
}

double parseTime(String input) {
  var hhMM = input.split(':');
  int hours = int.tryParse(hhMM[0]);
  int minutes = int.tryParse(hhMM[1]);

  if(hours == null || minutes == null || hhMM[1].length != 2) return null;

  return hours.toDouble() + minutes.toDouble()/60;

}


class Global {
  static List<Color> defaultColors = [
    Colors.blue,
    Colors.blueGrey,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.yellow,
    Colors.deepPurple,
    Colors.pink
  ];
}

