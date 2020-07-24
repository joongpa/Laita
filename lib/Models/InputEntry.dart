import 'package:intl/intl.dart';
import 'package:miatracker/Models/DataStorageHelper.dart';

import '../Map.dart';
import 'Entry.dart';

class InputEntry extends Entry{
  String description;

  InputEntry({id, dateTime, this.description, inputType, amount}) :
        super(id: id, dateTime: dateTime, inputType: inputType, amount: amount);

  InputEntry.now({id, this.description, inputType, amount}) :
        super.now(id: id, inputType: inputType, amount: amount);

  InputEntry.explicitTime({id, date, time, this.description, inputType, amount}) :
        super.explicitTime(id: id, date: date, time: time, inputType: inputType, amount: amount);

  factory InputEntry.fromMap(Map<String,dynamic> map) => InputEntry.explicitTime(
    id: map['id'],
    date: map['date'],
    time: map['time'],
    description: map['description'],
    inputType: DataStorageHelper().getCategory(map['inputType']),
    amount: map['duration']
  );

  @override
  Map<String,dynamic> toMap() => {
    "date": date,
    "time": time,
    "description": description,
    "inputType": inputType.name,
    "duration": amount
  };
}