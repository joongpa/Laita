import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:miatracker/Models/Entry.dart';
import 'package:miatracker/Models/aggregate_data_model.dart';
import '../Map.dart';
import 'GoalEntry.dart';
import 'InputEntry.dart';
import 'category.dart';

class DatabaseService {
  DatabaseService._();

  final String _inputEntries = 'inputEntries';
  final String _goalEntries = 'goalEntries';
  final String _categories = 'categories';
  final String _aggregateInputEntries = 'aggregateInputEntries';

  static Map<DateTime, List<Entry>> _entries = Map<DateTime, List<Entry>>();
  static Map<DateTime, DailyInputEntry> _aggregateEntries =
      Map<DateTime, DailyInputEntry>();

  static final DatabaseService instance = DatabaseService._();

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

  Stream<GoalEntry> lastGoalEntry(FirebaseUser user, Category category) {
    var ref = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection(_goalEntries);

    return ref
        .where('inputType', isEqualTo: category.name)
        .orderBy('dateTime', descending: true)
        .limit(1)
        .snapshots()
        .map((list) => list.documents
            .map((doc) => GoalEntry.fromMap(doc.data, doc.documentID))
            .first);
  }

  Stream<List<Category>> categoriesStream(FirebaseUser user) {
    var ref = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection(_categories);

    return ref.orderBy('dateTime').snapshots().map((list) => list.documents
        .map((doc) => Category.fromMap(doc.data, doc.documentID))
        .toList());
  }

  Future<bool> addInputEntry(FirebaseUser user, InputEntry inputEntry) async {
    _entries[daysAgo(0, inputEntry.dateTime)].add(inputEntry);

    var ref = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection(_inputEntries);

    try {
      await ref.add(inputEntry.toMap());
      _updateAggregateData(user, inputEntry);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> addGoalEntry(FirebaseUser user, GoalEntry goalEntry) async {
    _entries[daysAgo(0, goalEntry.dateTime)].add(goalEntry);
    var ref = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection(_goalEntries);
    try {
      await ref.add(goalEntry.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addCategory(FirebaseUser user, Category category) async {
    var ref = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection(_categories);
    int size;
    await ref
        .where('name', isEqualTo: category.name)
        .getDocuments()
        .then((value) => size = value.documents.length);
    if (size == 0) {
      try {
        await ref.add(category.toMap());
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<bool> deleteInputEntry(
      FirebaseUser user, InputEntry inputEntry) async {
    _entries[daysAgo(0, inputEntry.dateTime)].remove(inputEntry);
    var ref = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection(_inputEntries);
    try {
      await ref.document(inputEntry.docID).delete();
      _updateAggregateData(user, inputEntry, isDelete: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteGoalEntry(FirebaseUser user, GoalEntry goalEntry) async {
    _entries[daysAgo(0, goalEntry.dateTime)].remove(goalEntry);
    var ref = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection(_goalEntries);
    try {
      await ref.document(goalEntry.docID).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteCategory(FirebaseUser user, Category category) async {
    var ref = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection(_categories);
    try {
      await ref.document(category.docID).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  ///Specialized Methods

  Future<List<Entry>> getEntriesOnDay(FirebaseUser user, DateTime day) async {
    if (_entries[day] == null) {
      final temp = await _getEntriesAsFuture(user, dateTime: day);
      _entries[day] = temp;
    }
    return _entries[day] ?? [];
  }

  Future<List<Entry>> _getEntriesAsFuture(FirebaseUser user,
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

  Future<Map<DateTime, DailyInputEntry>> getTotalInputHoursOnDays(
      FirebaseUser user,
      {@required DateTime startDate,
      @required DateTime endDate}) async {
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
      FirebaseUser user, DateTime startDate, DateTime endDate) async {
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

  Stream<DailyInputEntry> dailyProgressStream(FirebaseUser user) {
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

  void _updateAggregateData(FirebaseUser user, InputEntry inputEntry,
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
        } catch (e){}

        if (freshSnap == null) {
          if (!isDelete) {
            ref2.add(DailyInputEntry(
                dateTime: inputEntry.dateTime,
                categoryHours: <String, dynamic>{
                  inputEntry.inputType: inputEntry.amount
                }).toMap());
          }
        } else {
          final agData = DailyInputEntry.fromMap(freshSnap.data, freshSnap.reference.documentID);
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
