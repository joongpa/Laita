import 'package:intl/intl.dart';
import 'package:miatracker/Models/DataStorageHelper.dart';
import 'package:miatracker/Models/Entry.dart';

import '../Map.dart';

class GoalEntry extends Entry{

  GoalEntry({id, dateTime, inputType, amount}) :
      super(id: id, dateTime: dateTime, inputType: inputType, amount: amount);

  GoalEntry.now({id, inputType, amount}) :
        super.now(id: id, inputType: inputType, amount: amount);

  GoalEntry.explicitTime({id, date, time, inputType, amount}) :
        super.explicitTime(id: id, date: date, time: time, inputType: inputType, amount: amount);

  factory GoalEntry.fromMap(Map<String,dynamic> map) => GoalEntry.explicitTime(
      id: map['id'],
      date: map['date'],
      time: map['time'],
      inputType: DataStorageHelper().getCategory(map['inputType']),
      amount: map['duration']
  );

  @override
  Map<String,dynamic> toMap() => {
    "date": date,
    "time": time,
    "inputType": inputType.name,
    "duration": amount
  };
}