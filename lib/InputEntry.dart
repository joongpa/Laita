import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import 'Map.dart';

class InputEntry {
  int id;
  DateTime dateTime;
  String date;
  String time;
  String description;
  InputType inputType;
  double duration;

  InputEntry({this.id, this.dateTime, this.description, this.inputType, this.duration}) {
    date = DateFormat("yyyy-MM-dd").format(dateTime);
    time = DateFormat("HH:mm").format(dateTime);
  }

  InputEntry.now({this.id, this.description, this.inputType, this.duration}) {
    dateTime = DateTime.now();
    date = DateFormat("yyyy-MM-dd").format(dateTime);
    time = DateFormat("HH:mm").format(dateTime);
  }

  InputEntry.explicitTime({this.id, this.date, this.time, this.description, this.inputType, this.duration}) {
    dateTime = DateTime.parse('$date $time');
  }

  factory InputEntry.fromMap(Map<String,dynamic> map) => InputEntry.explicitTime(
    id: map['id'],
    date: map['date'],
    time: map['time'],
    description: map['description'],
    inputType: _stringToEnum(map['inputType']),
    duration: map['duration']
  );

  Map<String,dynamic> toMap() => {
    "date": date,
    "time": time,
    "description": description,
    "inputType": inputType.name,
    "duration": duration
  };

  static InputType _stringToEnum(String string) {
    switch(string) {
      case "Reading":
        return InputType.Reading;
      case "Listening":
        return InputType.Listening;
      case "Anki":
        return InputType.Anki;
    }
    return null;
  }
}