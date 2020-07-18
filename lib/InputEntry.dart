import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import 'Map.dart';

class InputEntry {
  int id;
  DateTime dateTime;
  String time;
  String description;
  InputType inputType;
  double duration;

  InputEntry.now({this.description, this.inputType, this.duration}) {
    dateTime = DateTime.now();
    time = DateFormat("kk:mm").format(dateTime);
  }

  InputEntry({this.id, this.dateTime, this.description, this.inputType, this.duration}) {
    time = DateFormat("kk:mm").format(dateTime);
  }

  factory InputEntry.fromMap(Map<String,dynamic> map) => InputEntry(
    id: map['id'],
    dateTime: DateTime.parse(map['dateTime']),
    description: map['description'],
    inputType: _stringToEnum(map['inputType']),
    duration: map['duration']
  );

  Map<String,dynamic> toMap() => {
    "dateTime": dateTime.toString(),
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