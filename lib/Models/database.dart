import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:miatracker/Models/Entry.dart';
import 'package:miatracker/Models/aggregate_data_model.dart';
import '../Map.dart';
import 'GoalEntry.dart';
import 'InputEntry.dart';
import 'user.dart';

class DatabaseService {
  DatabaseService._();

  final String _inputEntries = 'inputEntries';
  final String _goalEntries = 'goalEntries';
  final String _aggregateInputEntries = 'aggregateInputEntries';

  static Map<DateTime, List<Entry>> _entries = Map<DateTime, List<Entry>>();
  static Map<DateTime, DailyInputEntry> _aggregateEntries =
      Map<DateTime, DailyInputEntry>();

  static final DatabaseService instance = DatabaseService._();

  Stream<AppUser> appUserStream(FirebaseUser user) {
    var ref = Firestore.instance.collection('users').document(user.uid);

    return ref.snapshots().map((value) => AppUser.fromMap(value.data));
  }

  Stream<List<InputEntry>> inputEntriesStream(FirebaseUser user,
      {Category category, DateTime startDate, DateTime endDate}) {
    var ref = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection(_inputEntries);

    if (startDate == null && endDate == null && category == null) {
      return ref.snapshots().map((list) => list.documents
          .map((doc) => InputEntry.fromMap(doc.data, doc.documentID))
          .toList());
    } else if (startDate == null && endDate == null) {
      return ref.where('category', isEqualTo: category.name).snapshots().map(
          (list) => list.documents
              .map((doc) => InputEntry.fromMap(doc.data, doc.documentID))
              .toList());
    }
    startDate ??= DateTime.now();
    endDate ??= daysAgo(-1, DateTime.now());

    return ref
        .where('category', isEqualTo: category.name)
        .where('dateTime', isGreaterThanOrEqualTo: startDate)
        .where('dateTime', isLessThan: endDate)
        .snapshots()
        .map((list) => list.documents
            .map((doc) => InputEntry.fromMap(doc.data, doc.documentID))
            .toList());
  }

  Stream<List<GoalEntry>> goalEntriesStream(FirebaseUser user,
      {Category category, DateTime startDate, DateTime endDate}) {
    var ref = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection(_goalEntries);

    if (startDate == null && endDate == null && category == null) {
      return ref.snapshots().map((list) => list.documents
          .map((doc) => GoalEntry.fromMap(doc.data, doc.documentID))
          .toList());
    } else if (startDate == null && endDate == null) {
      return ref.where('category', isEqualTo: category.name).snapshots().map(
          (list) => list.documents
              .map((doc) => GoalEntry.fromMap(doc.data, doc.documentID))
              .toList());
    }
    startDate ??= DateTime.now();
    endDate ??= daysAgo(-1, DateTime.now());

    return ref
        .where('category', isEqualTo: category.name)
        .where('dateTime', isGreaterThanOrEqualTo: startDate)
        .where('dateTime', isLessThan: endDate)
        .snapshots()
        .map((list) => list.documents
            .map((doc) => GoalEntry.fromMap(doc.data, doc.documentID))
            .toList());
  }

  Future<bool> addInputEntry(AppUser user, InputEntry inputEntry) async {
    var ref = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection(_inputEntries);

    try {
      final docRef = await ref.add(inputEntry.toMap());
      _updateAggregateData(user, inputEntry);
      inputEntry.docID = docRef.documentID;
      _entries[daysAgo(0, inputEntry.dateTime)].add(inputEntry);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> addGoalEntry(AppUser user, GoalEntry goalEntry) async {
    var ref = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection(_goalEntries);

    try {
      int index = user.categories.indexOf(Category(name: goalEntry.inputType));
      if(index >= 0 && user.categories[index].goalAmount == goalEntry.amount)
        return false;

      final docRef = await ref.add(goalEntry.toMap());
      goalEntry.docID = docRef.documentID;
      _updateAggregateGoalData(user, goalEntry);
      _entries[daysAgo(0, goalEntry.dateTime)].add(goalEntry);
      return true;
    } catch (e) {
      return false;
    }
  }

  void updateCategories(AppUser user, {Category category, bool isDelete}) {
    var userRef = Firestore.instance.collection('users').document(user.uid);
    if (isDelete) {
      user.categories.remove(category);
      userRef.setData(user.toMap());
    } else {
      //2 categories cannot have the same name
      int index = user.categories.indexOf(category);

      if(index == -1) {
        user.categories.add(category);
        userRef.setData(user.toMap());
      }
    }
  }

  Future<bool> deleteInputEntry(AppUser user, InputEntry inputEntry) async {
    var ref = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection(_inputEntries);
    try {
      await ref.document(inputEntry.docID).delete();
      _entries[daysAgo(0, inputEntry.dateTime)].remove(inputEntry);
      _updateAggregateData(user, inputEntry, isDelete: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  ///Specialized Methods

  Future<List<Entry>> getEntriesOnDay(AppUser user, DateTime day) async {
    if (_entries[day] == null) {
      final temp = await _getEntriesAsFuture(user, dateTime: day);
      _entries[day] = temp;
    }
    return _entries[day] ?? [];
  }

  Future<List<Entry>> _getEntriesAsFuture(AppUser user,
      {DateTime dateTime}) async {
    var inputRef = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection(_inputEntries);
    var goalRef = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection(_goalEntries);
    List<Entry> tempList = [];

    final iSnap = await inputRef
        .where('dateTime', isGreaterThanOrEqualTo: dateTime)
        .where('dateTime', isLessThan: daysAgo(-1, dateTime))
        .getDocuments();

    final gSnap = await goalRef
        .where('dateTime', isGreaterThanOrEqualTo: dateTime)
        .where('dateTime', isLessThan: daysAgo(-1, dateTime))
        .getDocuments();

    List<InputEntry> iEntries = iSnap.documents
        .map<InputEntry>((doc) => InputEntry.fromMap(doc.data, doc.documentID))
        .toList();
    List<GoalEntry> gEntries = gSnap.documents
        .map<GoalEntry>((doc) => GoalEntry.fromMap(doc.data, doc.documentID))
        .toList();

    tempList.addAll(iEntries);
    tempList.addAll(gEntries);
    tempList.sort();

    return tempList;
  }

  Future<Map<DateTime, DailyInputEntry>> getTotalInputHoursOnDays(AppUser user,
      {@required DateTime startDate, @required DateTime endDate}) async {
    for (int i = 1; i <= daysBetween(startDate, endDate); i++) {
      final tempEntry = _aggregateEntries[daysAgo(i, endDate)];
      if (tempEntry == null) {
        _aggregateEntries.addAll(await _getMissingAggregateEntries(
            user, daysAgo(0, startDate), daysAgo(i - 1, endDate)));
      } else {
        _aggregateEntries[daysAgo(i, endDate)] = tempEntry;
      }
    }
    return _aggregateEntries ?? {};
  }

  Future<Map<DateTime, DailyInputEntry>> _getMissingAggregateEntries(
      AppUser user, DateTime startDate, DateTime endDate) async {
    var ref = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection(_aggregateInputEntries);
    final agSnap = await ref
        .where('dateTime', isGreaterThanOrEqualTo: startDate)
        .where('dateTime', isLessThan: endDate)
        .getDocuments();
    final List<DailyInputEntry> tempList = agSnap.documents
        .map((e) => DailyInputEntry.fromMap(e.data, e.documentID))
        .toList();
    final List<DateTime> dates =
        List.generate(tempList.length, (index) => daysAgo(-index, startDate));
    final Map<DateTime, DailyInputEntry> tempMap =
        Map.fromIterables(dates, tempList);
    return tempMap ?? {};
  }

  Stream<DailyInputEntry> dailyProgressStream(AppUser user) {
    var ref = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection(_aggregateInputEntries);

    return ref
        .where('dateTime', isGreaterThanOrEqualTo: daysAgo(0))
        .where('dateTime', isLessThan: daysAgo(-1))
        .limit(1)
        .snapshots()
        .map((list) => list.documents
            .map((doc) => DailyInputEntry.fromMap(doc.data, doc.documentID))
            .first);
  }

  void _updateAggregateGoalData(AppUser user, GoalEntry goalEntry) {
    var ref2 = Firestore.instance.collection('users').document(user.uid);
    try {
      int index = user.categories.indexOf(Category(name: goalEntry.inputType));
      if(index == -1) return;

      user.categories[index].goalAmount = goalEntry.amount;
      ref2.setData(user.toMap(), merge: true);
    } catch (e) {}
  }

  void _updateAggregateData(AppUser user, InputEntry inputEntry,
      {bool isDelete = false}) {
    var ref2 = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection(_aggregateInputEntries);

    ref2
        .where('dateTime', isEqualTo: daysAgo(0, inputEntry.dateTime))
        .limit(1)
        .getDocuments()
        .then((value) {
      Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot freshSnap;

        try {
          DocumentReference docRef = value.documents.first.reference;
          freshSnap = await transaction.get(docRef);
        } catch (e) {}

        if (freshSnap == null) {
          if (!isDelete) {
            ref2.add(DailyInputEntry(
                dateTime: inputEntry.dateTime,
                categoryHours: <String, dynamic>{
                  inputEntry.inputType: inputEntry.amount
                }).toMap());
          }
        } else {
          final agData = DailyInputEntry.fromMap(
              freshSnap.data, freshSnap.reference.documentID);
          agData.categoryHours[inputEntry.inputType] =
              ((isDelete) ? -1 : 1) * inputEntry.amount +
                  (agData.categoryHours[inputEntry.inputType] ?? 0.0);
          await transaction.update(freshSnap.reference, agData.toMap());
        }
      });
    });
  }

  clearCache() {
    _entries.clear();
    _aggregateEntries.clear();
  }
}
