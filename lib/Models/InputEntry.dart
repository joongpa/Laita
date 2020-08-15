
import 'Entry.dart';

class InputEntry extends Entry{
  String description;

  InputEntry({docID, dateTime, this.description, inputType, amount}) :
        super(docID: docID, dateTime: dateTime, inputType: inputType, amount: amount);

  InputEntry.now({docID, this.description, inputType, amount}) :
        super.now(docID: docID, inputType: inputType, amount: amount);

  factory InputEntry.fromMap(Map<String,dynamic> map) => InputEntry(
    docID: map['docID'],
    dateTime: map['dateTime'].toDate(),
    description: map['description'],
    inputType: map['inputType'],
    amount: map['duration']
  );

  @override
  Map<String,dynamic> toMap() => {
    "docID": docID,
    "dateTime": dateTime,
    "description": description,
    "inputType": inputType,
    "duration": amount
  };
}