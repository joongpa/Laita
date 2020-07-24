import 'package:intl/intl.dart';
import 'package:miatracker/Models/DataStorageHelper.dart';

import '../Map.dart';

abstract class Entry implements Comparable<Entry>{
  int id;
  DateTime dateTime;
  String date;
  String time;
  Category inputType;
  double amount;

  Entry({this.id, this.dateTime, this.inputType, this.amount}) {
    date = DateFormat("yyyy-MM-dd").format(dateTime);
    time = DateFormat("HH:mm").format(dateTime);
  }

  Entry.now({this.id, this.inputType, this.amount}) {
    dateTime = DateTime.now();
    date = DateFormat("yyyy-MM-dd").format(dateTime);
    time = DateFormat("HH:mm").format(dateTime);
  }

  Entry.explicitTime({this.id, this.date, this.time, this.inputType, this.amount}) {
    dateTime = DateTime.parse('$date $time');
  }

  Map<String,dynamic> toMap();

  @override
  int compareTo(Entry other) {
    return this.dateTime.compareTo(other.dateTime);
  }
}