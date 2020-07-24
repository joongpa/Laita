import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

import '../Map.dart';
import 'Entry.dart';
import 'GoalEntry.dart';
import 'InputEntry.dart';

class InputHoursUpdater {

  InputHoursUpdater._();
  static final InputHoursUpdater ihu = InputHoursUpdater._();

  BehaviorSubject _update = BehaviorSubject.seeded(0.0);
  Stream get updateStream$ => _update.stream;

  BehaviorSubject<List<InputEntry>> _dbChanges = BehaviorSubject.seeded([]);
  Stream get dbChangesStream$ => _dbChanges.stream;

  BehaviorSubject<List<GoalEntry>> _goalDbChanges = BehaviorSubject.seeded([]);
  Stream get goalDbChangesStream$ => _goalDbChanges.stream;

  void resumeUpdate() {
    _update.add(1.0);
  }

  void addEntry(List<InputEntry> data) {
    _dbChanges.add(data);
  }

  void addGoalEntry(List<GoalEntry> data) {
    _goalDbChanges.add(data);
  }
}

class Filter {

  static double getTotalInput(List<InputEntry> entries, {Category category, DateTime startDate, DateTime endDate}) {
    final tempList = filterEntries(entries, category: category, startDate: startDate, endDate: endDate);
    double sum = 0;

    for(final item in tempList) {
      sum += item.amount;
    }
    return sum;
  }

  static List<Entry> filterEntries(List<Entry> entries, {Category category, DateTime startDate, DateTime endDate}) {
    startDate ??= DateTime.now();
    endDate ??= daysAgo(-1, DateTime.now());
    final tempList = entries.where((inputEntry) => ((category != null) ? (inputEntry.inputType == category) : true) && (inputEntry.dateTime.isAtSameMomentAs(startDate) || inputEntry.dateTime.isAfter(startDate)) && inputEntry.dateTime.isBefore(endDate)).toList();
    return tempList;
  }
}