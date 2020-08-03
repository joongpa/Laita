import 'package:intl/intl.dart';
import 'package:miatracker/Models/DataStorageHelper.dart';
import 'package:miatracker/Models/Entry.dart';

import '../Map.dart';

class GoalEntry extends Entry{

  GoalEntry({docID, dateTime, inputType, amount}) :
      super(docID: docID, dateTime: dateTime, inputType: inputType, amount: amount);

  GoalEntry.now({docID, inputType, amount}) :
        super.now(docID: docID, inputType: inputType, amount: amount);

  factory GoalEntry.fromMap(Map<String,dynamic> map, [String docID]) => GoalEntry(
      docID: docID,
      dateTime: map['dateTime'].toDate(),
      inputType: map['inputType'],
      amount: map['duration']
  );

  @override
  Map<String,dynamic> toMap() => {
    "docID": docID,
    "dateTime": dateTime,
    "inputType": inputType,
    "duration": amount
  };
}