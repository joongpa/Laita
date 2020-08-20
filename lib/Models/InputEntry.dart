import 'Entry.dart';

class InputEntry extends Entry {
  String description;
  int mediaID;
  int episodesWatched;

  InputEntry({docID, dateTime, this.mediaID, this.episodesWatched, this.description, inputType, amount})
      : super(
            docID: docID,
            dateTime: dateTime,
            inputType: inputType,
            amount: amount);

  InputEntry.now({docID, this.description, inputType, amount})
      : super.now(docID: docID, inputType: inputType, amount: amount);

  factory InputEntry.fromMap(Map<String, dynamic> map) => InputEntry(
      docID: map['docID'],
      dateTime: map['dateTime'].toDate(),
      description: map['description'],
      mediaID: map['mediaID'],
      episodesWatched: map['episodesWatched'],
      inputType: map['inputType'],
      amount: map['duration']);

  @override
  Map<String, dynamic> toMap() => {
        "docID": docID,
        "dateTime": dateTime,
        "description": description,
        "mediaID": mediaID,
        "episodesWatched": episodesWatched,
        "inputType": inputType,
        "duration": amount
      };
}
