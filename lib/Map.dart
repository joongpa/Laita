import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

enum InputType {
  Reading, Listening, Anki
}

extension InputTypeExtension on InputType {
  String get name => describeEnum(this);
}

int daysBetween(DateTime d1, DateTime d2) {
  d1 = DateTime(d1.year, d1.month, d1.day);
  d2 = DateTime(d2.year, d2.month, d2.day);
  return d1.difference(d2).inDays.abs();
}

bool sameDay(DateTime date, DateTime date2) {
  return (date.year == date2.year) && (date.month == date2.month) && (date.day == date2.day);
}

DateTime daysAgo(int days, [DateTime dateTime]) {
  dateTime = dateTime ?? DateTime.now();
  return DateTime(dateTime.year, dateTime.month, dateTime.day - days);
}



class UsefulShit {

  UsefulShit._();

  static final doubleDecimalFormat = NumberFormat("0.00");
  static final leadingZeroFormat = NumberFormat("00");

  static String convertToTime(double time) {
    int hours = time.floor();
    int minutes = ((time % 1) * 60).round();

    return '$hours:${leadingZeroFormat.format(minutes)}';
  }
}