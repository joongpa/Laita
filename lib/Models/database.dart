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

    return ref.snapshots().map((doc) => AppUser.fromMap(doc.data));
  }

  Future<bool> addInputEntry(AppUser user, InputEntry inputEntry) async {
    var ref = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection(_inputEntries);

    try {
      final docID =
          '${inputEntry.dateTime} ${inputEntry.inputType} ${inputEntry.amount} ${UniqueKey().hashCode}';
      inputEntry.docID = docID;
      _updateAggregateData(user, inputEntry);

      if (_entries[daysAgo(0, inputEntry.dateTime)] != null) {
        _entries[daysAgo(0, inputEntry.dateTime)].add(inputEntry);
      }

      await ref.document(docID).setData(inputEntry.toMap());

      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> deleteInputEntry(AppUser user, InputEntry inputEntry) async {
    var ref = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection(_inputEntries);
    try {
      _entries[daysAgo(0, inputEntry.dateTime)].remove(inputEntry);
      _updateAggregateData(user, inputEntry, isDelete: true);
      await ref.document(inputEntry.docID).delete();
      return true;
    } catch (e) {
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
      if (index >= 0 && user.categories[index].goalAmount == goalEntry.amount)
        return false;

      final docID =
          '${goalEntry.dateTime} ${goalEntry.inputType} ${goalEntry.amount}';
      goalEntry.docID = docID;
      _updateAggregateGoalData(user, goalEntry);
      _entries[daysAgo(0, goalEntry.dateTime)].add(goalEntry);

      await ref.document(docID).setData(goalEntry.toMap());

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

      if (index == -1) {
        user.categories.add(category);
        userRef.setData(user.toMap(), merge: true);
      }
    }
  }

  void editUser(AppUser user) {
    var userRef = Firestore.instance.collection('users').document(user.uid);
    userRef.setData(user.toMap());
  }

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

  Future<Map<DateTime, DailyInputEntry>> getTotalInputHoursOnDays(String uid,
      {@required DateTime startDate, @required DateTime endDate}) async {
    Map<DateTime, DailyInputEntry> tempMap = {};
    for (int i = 1; i <= daysBetween(startDate, endDate); i++) {
      if (_aggregateEntries[daysAgo(i, endDate)] == null) {
        _aggregateEntries.addAll(await _getMissingAggregateEntries(
            uid, daysAgo(0, startDate), daysAgo(i - 1, endDate)));
      }
      tempMap[daysAgo(i, endDate)] = _aggregateEntries[daysAgo(i, endDate)];
    }
    tempMap[startDate] ??= DailyInputEntry(
        dateTime: startDate, categoryHours: {}, goalAmounts: {});
    tempMap[endDate] ??=
        DailyInputEntry(dateTime: endDate, categoryHours: {}, goalAmounts: {});
    return tempMap ?? {};
  }

  Future<Map<DateTime, DailyInputEntry>> _getMissingAggregateEntries(
      String uid, DateTime startDate, DateTime endDate) async {
    var ref = Firestore.instance
        .collection('users')
        .document(uid)
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
    Map<DateTime, DailyInputEntry> tempMap = Map.fromIterables(dates, tempList);
    return tempMap ?? {};
  }

  Stream<Map<DateTime, DailyInputEntry>> dailyInputEntriesStream(String uid,
      {@required DateTime startDate, @required DateTime endDate}) {
    var ref = Firestore.instance
        .collection('users')
        .document(uid)
        .collection(_aggregateInputEntries);

    return ref
        .where('dateTime',
            isGreaterThanOrEqualTo: startDate, isLessThan: endDate)
        .snapshots()
        .map((list) {
      var map = Map<DateTime, DailyInputEntry>.fromIterables(
          list.documents
              .map<DateTime>((doc) => doc.data['dateTime'].toDate())
              .toList(),
          list.documents
              .map((doc) => DailyInputEntry.fromMap(doc.data))
              .toList());
      map[startDate] ??= DailyInputEntry(
          dateTime: startDate, categoryHours: {}, goalAmounts: {});
      map[endDate] ??= DailyInputEntry(
          dateTime: endDate, categoryHours: {}, goalAmounts: {});
      return map;
    });
  }

  void _updateAggregateGoalData(AppUser user, GoalEntry goalEntry) {
    var ref2 = Firestore.instance.collection('users').document(user.uid);
    try {
      categoryFromName(goalEntry.inputType, user.categories).goalAmount =
          goalEntry.amount;

      ref2.setData(user.toMap(), merge: true);
    } catch (e) {}
  }

  void _updateAggregateData(AppUser user, InputEntry inputEntry,
      {bool isDelete = false}) {
    String docID = daysAgo(0, inputEntry.dateTime).toString();

    DocumentReference docRef = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection(_aggregateInputEntries)
        .document(docID);

    docRef.get().then((value) {
      Firestore.instance.runTransaction(
        (transaction) async {
          DocumentSnapshot freshSnap;

          try {
            if (value.exists) freshSnap = await transaction.get(docRef);
          } catch (e) {}

          if (freshSnap == null) {
            if (!isDelete) {
              var goalRef = Firestore.instance
                  .collection('users')
                  .document(user.uid)
                  .collection('goalEntries');

              var snap = await goalRef
                  .where('dateTime',
                      isLessThan: daysAgo(-1, inputEntry.dateTime))
                  .orderBy('dateTime')
                  .limit(1)
                  .getDocuments();
              double amount;
              try {
                amount = snap.documents
                    .map((e) => GoalEntry.fromMap(e.data))
                    .first
                    .amount;
              } catch (e) {
                amount = 0;
              }
              await transaction.set(
                docRef,
                DailyInputEntry(
                    dateTime: inputEntry.dateTime,
                    categoryHours: <String, dynamic>{
                      inputEntry.inputType: inputEntry.amount
                    },
                    goalAmounts: <String, dynamic>{
                      inputEntry.inputType: amount,
                    }).toMap(),
              );
            }
          } else {
            final agData = DailyInputEntry.fromMap(freshSnap.data);
            agData.categoryHours[inputEntry.inputType] =
                (((isDelete) ? -1 : 1) * inputEntry.amount) +
                    (agData.categoryHours[inputEntry.inputType] ?? 0.0);
            if (sameDay(inputEntry.dateTime, DateTime.now())) {
              agData.goalAmounts[inputEntry.inputType] =
                  categoryFromName(inputEntry.inputType, user.categories)
                      .goalAmount;
            }
            await transaction.set(docRef, agData.toMap());
          }
        },
      );
    });
    _updateLifetimeAmounts(user.uid, inputEntry, isDelete: isDelete);
  }

  void _updateLifetimeAmounts(String uid, InputEntry inputEntry,
      {bool isDelete = false}) {
    DocumentReference docRef =
        Firestore.instance.collection('users').document(uid);

    Firestore.instance.runTransaction((transaction) async {
      AppUser user = AppUser.fromMap((await transaction.get(docRef)).data);
      try {
        categoryFromName(inputEntry.inputType, user.categories)
            .lifetimeAmount += ((isDelete) ? -1 : 1) * inputEntry.amount;
      } catch (e) {}
      await transaction.update(docRef, user.toMap());
    });
  }

  clearCache() {
    _entries.clear();
    _aggregateEntries.clear();
  }
}
