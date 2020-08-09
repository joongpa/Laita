import 'package:flutter/cupertino.dart';
import 'package:miatracker/Models/user.dart';
import 'package:rxdart/rxdart.dart';

import 'category.dart';
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
  static double getTotalInput(List<InputEntry> entries,
      {Category category, DateTime startDate, DateTime endDate}) {

    final tempList = filterEntries(entries,
        category: category, startDate: startDate, endDate: endDate);

    double sum = 0;

    for (final item in tempList) {
      sum += item.amount;
    }
    return sum;
  }

  static List<Entry> filterEntries(List<Entry> entries,
      {Category category, DateTime startDate, DateTime endDate}) {
    if (startDate == null && endDate == null) {
      return entries
          .where((inputEntry) =>
      ((category != null) ? (inputEntry.inputType == category.name) : true))
          .toList();
    } else {
      startDate ??= DateTime.now();
      endDate ??= daysAgo(-1, DateTime.now());
      final tempList = entries
          .where((inputEntry) =>
      ((category != null) ? (inputEntry.inputType == category.name) : true) &&
          (inputEntry.dateTime.isAtSameMomentAs(startDate) ||
              inputEntry.dateTime.isAfter(startDate)) &&
          inputEntry.dateTime.isBefore(endDate))
          .toList();
      return tempList;
    }
  }

  static List<double> totalInputPerDay(List<InputEntry> entries,
      {@required Category category,
      @required DateTime startDate,
      @required DateTime endDate}) {
    final List<double> totalsPerDay =
        List.generate(daysBetween(startDate, endDate), (i) => 0.0);

    for (int i = 0; i < totalsPerDay.length; i++) {
      totalsPerDay[i] = getTotalInput(entries,
          category: category,
          startDate: daysAgo(-i, startDate),
          endDate: daysAgo(-i - 1, startDate));
    }
    return totalsPerDay;
  }

  //currently iterates through entire list for each day
  //instead, it should go to first instance of goal entry before given time-frame
  static List<double> goalsPerDay(List<GoalEntry> entries,
      {@required Category category,
      @required DateTime startDate,
      @required DateTime endDate}) {
    final List<double> totalsPerDay =
        List.generate(daysBetween(startDate, endDate), (i) => 0.0);
    entries = filterEntries(entries, category: category);
    entries.sort();
    if(entries.length == 0) return totalsPerDay;

    int index = 0;

    if (entries[0].dateTime.isAfter(startDate))
      index = daysBetween(entries[0].dateTime, startDate);

    for (int i = 0; i < entries.length; i++) {
      final goalEntry = entries[i];

      if (i < entries.length - 1) {
        if (sameDay(goalEntry.dateTime, entries[i + 1].dateTime)) {
          continue;
        }
      }

      int daysAfterGoal = 0;
      bool noGoalEntry = true;

      while (noGoalEntry && index < totalsPerDay.length) {
        if (!daysAgo(-daysAfterGoal, goalEntry.dateTime).isBefore(startDate)) {
          totalsPerDay[index] = goalEntry.amount;
          index++;
        }
        daysAfterGoal++;
        noGoalEntry = filterEntries(entries,
                    category: category,
                    startDate: daysAgo(-daysAfterGoal, goalEntry.dateTime),
                    endDate: daysAgo(-daysAfterGoal - 1, goalEntry.dateTime))
                .length ==
            0;
      }
    }
    return totalsPerDay;
  }

  static int getCurrentStreak({
    @required List<InputEntry> inputEntries,
    @required List<GoalEntry> goalEntries,
    @required Category inputType,
  }) {
    final inputHours = totalInputPerDay(inputEntries, category: inputType, startDate: DateTime(2020,1,1), endDate: daysAgo(-1, DateTime.now()));
    final goalAmounts = goalsPerDay(goalEntries, category: inputType, startDate: DateTime(2020,1,1), endDate: daysAgo(-1, DateTime.now()));

    int streak = 0;
    bool keptStreak = true;
    int index = goalAmounts.length - 1;
    do {
      if(goalAmounts[index] == 0 && inputHours[index] == 0 && index != goalAmounts.length - 1) {
        keptStreak = false;
      } else if(inputHours[index] >= goalAmounts[index] && (goalAmounts[index] != 0 || inputHours[index] > 0)) {
        streak++;
      } else if(index != goalAmounts.length - 1) {
        keptStreak = false;
      }
      index--;
    } while(keptStreak && index >= 0);

    return streak;
  }
}
