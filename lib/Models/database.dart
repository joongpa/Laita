import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:miatracker/Models/Entry.dart';
import 'package:miatracker/Models/aggregate_data_model.dart';
import 'package:miatracker/Models/input_entries_provider.dart';
import 'package:rxdart/rxdart.dart';
import '../Map.dart';
import 'GoalEntry.dart';
import 'InputEntry.dart';
import 'user.dart';
import 'dart:math' as math;

class DatabaseService {
  DatabaseService._();

  final String _goalEntries = 'goalEntries';
  final String _aggregateInputEntries = 'aggregateInputEntries';

  Map<DateTime, DailyInputEntry> _aggregateEntries =
      Map<DateTime, DailyInputEntry>();

  static final DatabaseService instance = DatabaseService._();

  Stream<AppUser> appUserStream(FirebaseUser user) {
    var ref = Firestore.instance.collection('users').document(user.uid);

    return ref.snapshots().map((doc) => AppUser.fromMap(doc.data));
  }

  Future<bool> addInputEntry(AppUser user, InputEntry inputEntry) async {
    try {
      final docID =
          '${inputEntry.dateTime} ${inputEntry.inputType} ${inputEntry.amount} ${UniqueKey().hashCode}';
      inputEntry.docID = docID;
      _updateAggregateData(user, inputEntry);

      if (InputEntriesProvider
              .instance.entries[daysAgo(0, inputEntry.dateTime)] !=
          null) {
        InputEntriesProvider.instance.entries[daysAgo(0, inputEntry.dateTime)]
            .add(inputEntry);
      }
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> deleteInputEntry(AppUser user, InputEntry inputEntry) async {
    try {
      InputEntriesProvider.instance.entries[daysAgo(0, inputEntry.dateTime)]
          .remove(inputEntry);
      _updateAggregateData(user, inputEntry, isDelete: true);
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
      InputEntriesProvider.instance.entries[daysAgo(0, goalEntry.dateTime)]
          .add(goalEntry);

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

  Future<List<Entry>> getEntriesAsFuture(String uid,
      {DateTime dateTime}) async {
    var inputRef = Firestore.instance
        .collection('users')
        .document(uid)
        .collection(_aggregateInputEntries)
        .document(daysAgo(0, dateTime).toString());

    var goalRef = Firestore.instance
        .collection('users')
        .document(uid)
        .collection(_goalEntries);
    List<Entry> tempList = [];

    final gSnap = await goalRef
        .where('dateTime', isGreaterThanOrEqualTo: dateTime)
        .where('dateTime', isLessThan: daysAgo(-1, dateTime))
        .getDocuments();

    try {
      List<InputEntry> iEntries =
          DailyInputEntry.fromMap((await inputRef.get()).data).inputEntries;

      List<GoalEntry> gEntries = gSnap.documents
          .map<GoalEntry>((doc) => GoalEntry.fromMap(doc.data, doc.documentID))
          .toList();

      tempList.addAll(iEntries);
      tempList.addAll(gEntries);
      tempList.sort();
    } catch (e) {}
    return tempList;
  }

  Stream<Map<DateTime, DailyInputEntry>> getDailyInputEntriesOnDays(String uid,
      {@required DateTime startDate, @required DateTime endDate}) async* {
    if (_aggregateEntries[startDate] == null) {
      _aggregateEntries.addAll(await dailyInputEntriesStream(uid,
              startDate: startDate, endDate: endDate)
          .first);
    }
    yield Map.from(_aggregateEntries)
      ..removeWhere(
          (date, value) => date.isBefore(startDate) || date.isAfter(endDate));
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

  void _updateAggregateGoalData(AppUser user, GoalEntry goalEntry) async {
    var ref2 = Firestore.instance.collection('users').document(user.uid);
    var dailyInputEntryRef = ref2
        .collection(_aggregateInputEntries)
        .document(daysAgo(0, goalEntry.dateTime).toString());

    try {
      categoryFromName(goalEntry.inputType, user.categories).goalAmount =
          goalEntry.amount;
      ref2.setData(user.toMap(), merge: true);

      final goalMap = <String, dynamic>{};
      user.categories.forEach((element) {
        goalMap[element.name] = element.goalAmount;
      });
      goalMap[goalEntry.inputType] = goalEntry.amount;

      try {
        _aggregateEntries[daysAgo(0, goalEntry.dateTime)]
            .goalAmounts[goalEntry.inputType] = goalEntry.amount;
      } catch (e) {}

      dailyInputEntryRef.setData({'goalAmounts': goalMap}, merge: true);
    } catch (e) {}
  }

  void _updateAggregateData(AppUser user, InputEntry inputEntry,
      {bool isDelete = false}) {
    String docID = daysAgo(0, inputEntry.dateTime).toString();
    bool successfulDeletion = true;

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

          if (freshSnap == null && !isDelete) {
            double amount = await _getGoalOfInputEntry(user, inputEntry);
            final newDailyInputEntry = DailyInputEntry(
              dateTime: inputEntry.dateTime,
              categoryHours: <String, dynamic>{
                inputEntry.inputType: inputEntry.amount
              },
              goalAmounts: <String, dynamic>{
                inputEntry.inputType: amount
              },
              inputEntries: [inputEntry],
            );
            _aggregateEntries[daysAgo(0, inputEntry.dateTime)] =
                newDailyInputEntry;

            await transaction.set(
              docRef,
              newDailyInputEntry.toMap(),
            );
          } else {
            final agData = DailyInputEntry.fromMap(freshSnap.data);

            if (isDelete) {
              successfulDeletion = agData.inputEntries.remove(inputEntry);
            } else
              agData.inputEntries.add(inputEntry);

            agData.goalAmounts[inputEntry.inputType] ??= await _getGoalOfInputEntry(user, inputEntry);

            if (successfulDeletion) {
              agData.categoryHours[inputEntry.inputType] =
                  (((isDelete) ? -1 : 1) * inputEntry.amount) +
                      (agData.categoryHours[inputEntry.inputType] ?? 0.0);

              agData.categoryHours[inputEntry.inputType] = aboveZero(agData.categoryHours[inputEntry.inputType]);
            }

            _aggregateEntries[daysAgo(0, inputEntry.dateTime)] = agData;

            await transaction.set(docRef, agData.toMap());
          }
          _updateLifetimeAmounts(user.uid, inputEntry,
              isDelete: isDelete, notPhantomDelete: successfulDeletion);
        },
      );
    });
  }

  Future<double> _getGoalOfInputEntry(
      AppUser user, InputEntry inputEntry) async {

    if (sameDay(inputEntry.dateTime, DateTime.now())) {
      return categoryFromName(inputEntry.inputType, user.categories).goalAmount;
    }

    var goalRef = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('goalEntries');

    var snap = await goalRef
        .where('dateTime', isLessThan: daysAgo(-1, inputEntry.dateTime))
        .where('inputType', isEqualTo: inputEntry.inputType)
        .orderBy('dateTime')
        .limit(1)
        .getDocuments();

    double amount;
    try {
      amount =
          snap.documents.map((e) => GoalEntry.fromMap(e.data)).first.amount;
    } catch (e) {
      amount = 0;
    }

    return amount;
  }

  void _updateLifetimeAmounts(String uid, InputEntry inputEntry,
      {bool isDelete = false, bool notPhantomDelete = true}) {
    DocumentReference docRef =
        Firestore.instance.collection('users').document(uid);

    Firestore.instance.runTransaction((transaction) async {
      AppUser user = AppUser.fromMap((await transaction.get(docRef)).data);
      try {
        if (notPhantomDelete) {
          categoryFromName(inputEntry.inputType, user.categories)
              .lifetimeAmount += ((isDelete) ? -1 : 1) * inputEntry.amount;

          categoryFromName(inputEntry.inputType, user.categories)
              .lifetimeAmount = aboveZero(categoryFromName(inputEntry.inputType, user.categories)
              .lifetimeAmount);
        }
      } catch (e) {}
      await transaction.update(docRef, user.toMap());
    });
  }

  Stream<DailyInputEntry> getFirstDayOfActivity(String uid) {
    var ref = Firestore.instance
        .collection('users')
        .document(uid)
        .collection(_aggregateInputEntries);

    return ref.orderBy('dateTime').limit(1).snapshots().map((singleList) =>
        DailyInputEntry.fromMap(singleList.documents.first.data));
  }

  clearCache() {
    _aggregateEntries.clear();
  }

  double aboveZero(double num) {
    return math.max(num, 0);
  }
}
