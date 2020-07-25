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
    if(startDate == null && endDate == null)
      return entries.where((inputEntry) => ((category != null) ? (inputEntry.inputType == category) : true)).toList();

    startDate ??= DateTime.now();
    endDate ??= daysAgo(-1, DateTime.now());
    final tempList = entries.where((inputEntry) => ((category != null) ? (inputEntry.inputType == category) : true) && (inputEntry.dateTime.isAtSameMomentAs(startDate) || inputEntry.dateTime.isAfter(startDate)) && inputEntry.dateTime.isBefore(endDate)).toList();
    return tempList;
  }

  static List<double> totalInputPerDay(List<InputEntry> entries, {@required Category category, @required DateTime startDate, @required DateTime endDate}) {
    final List<double> totalsPerDay = List.generate(daysBetween(startDate, endDate), (i) => 0.0);

    for(int i = 0; i < totalsPerDay.length; i++) {
      totalsPerDay[i] = getTotalInput(entries, category: category, startDate: daysAgo(-i, startDate), endDate: daysAgo(-i - 1, startDate));
    }

    return totalsPerDay;
  }

  static List<double> goalsPerDay(List<GoalEntry> entries, {@required Category category, @required DateTime startDate, @required DateTime endDate}) {
    final List<double> totalsPerDay = List.generate(daysBetween(startDate, endDate), (i) => 0.0);
    entries = filterEntries(entries, category: category);

    int index = 0;
    for(final goalEntry in entries) {
      int daysAfterGoal = 0;
      bool noGoalEntry = filterEntries(entries, category: category, startDate: daysAgo(-1, goalEntry.dateTime), endDate: daysAgo(-2, goalEntry.dateTime)).length == 0;
      while(noGoalEntry) {
        if(daysAgo(-daysAfterGoal, goalEntry.dateTime).isBefore(startDate)) {
          noGoalEntry = filterEntries(entries, category: category, startDate: daysAgo(-daysAfterGoal - 1, goalEntry.dateTime), endDate: daysAgo(-daysAfterGoal - 2, goalEntry.dateTime)).length == 0;
          daysAfterGoal++;
          continue;
        }
        if(index == totalsPerDay.length) break;


        noGoalEntry = filterEntries(entries, category: category, startDate: daysAgo(-daysAfterGoal - 1, goalEntry.dateTime), endDate: daysAgo(-daysAfterGoal - 2, goalEntry.dateTime)).length == 0;
        totalsPerDay[index] = goalEntry.amount;
        daysAfterGoal++;
        index++;
      }
    }
    print('goals: $totalsPerDay');
    return totalsPerDay;
  }
}