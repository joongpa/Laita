import 'package:intl/intl.dart';

abstract class Entry implements Comparable<Entry>{
  String docID;
  DateTime dateTime;
  String inputType;
  double amount;

  Entry({this.docID, this.dateTime, this.inputType, this.amount});

  Entry.now({this.docID, this.inputType, this.amount}) {
    dateTime = DateTime.now();
  }

  String get time {
    return DateFormat.jm().format(this.dateTime);
  }

  Map<String,dynamic> toMap();

  @override
  int compareTo(Entry other) {
    return this.dateTime.compareTo(other.dateTime);
  }

  @override
  bool operator ==(other) {
    return other is Entry && docID == other.docID;
  }

  @override
  int get hashCode => docID.hashCode;

}