
import '../Map.dart';
import 'dart:math' as math;

import 'InputEntry.dart';

class DailyInputEntry {
  String docID;
  DateTime dateTime;
  Map<String, dynamic> categoryHours;
  Map<String, dynamic> goalAmounts;
  List<InputEntry> inputEntries;

  DailyInputEntry({this.docID, this.dateTime, this.categoryHours, this.goalAmounts, this.inputEntries}) {
    this.dateTime = daysAgo(0, dateTime);
  }

  factory DailyInputEntry.fromMap(Map<String, dynamic> map, [String docID]) {
    if(map == null) return null;

    List<InputEntry> tempList = [];
    try {
      tempList = List<InputEntry>.from(map['inputEntries'].map((i) => InputEntry.fromMap(i)));
    } catch (e) {}

    return DailyInputEntry(
    docID: docID,
    dateTime: (map['dateTime'] != null) ? map['dateTime'].toDate() : null,
    categoryHours: map['categoryHours'],
    goalAmounts: map['goalAmounts'],
    inputEntries: tempList,
  );
  }

  Map<String, dynamic> toMap() {
    var tempList = [];
    try {
      tempList = List<dynamic>.from(inputEntries.map((e) => e.toMap()));
    } catch (e) {print(e);}

    return {
    "docID": docID,
    "dateTime": dateTime,
    "categoryHours": categoryHours,
    'goalAmounts': goalAmounts,
    'inputEntries': tempList,
  };
  }

  @override
  bool operator ==(other) {
    return other is DailyInputEntry && sameDay(dateTime, other.dateTime);
  }

  @override
  int get hashCode => dateTime.hashCode;

}