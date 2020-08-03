//import 'package:flutter/material.dart';
//import 'package:miatracker/DailyGoalsTab/GlobalProgressWidget.dart';
//import 'package:miatracker/Models/DataStorageHelper.dart';
//import 'package:miatracker/Models/GoalEntry.dart';
//import 'package:miatracker/Models/InputEntry.dart';
//import 'package:miatracker/Models/InputHoursUpdater.dart';
//import 'package:provider/provider.dart';
//
//import '../Map.dart';
//
//class CompositeProgressWidget extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    final providedInputEntries = Provider.of<List<InputEntry>>(context);
//    final providedGoalEntries = Provider.of<List<GoalEntry>>(context);
//
//    if (providedInputEntries == null) return Container();
//
//    final todayEntries = providedInputEntries
//        .where((inputEntry) => sameDay(DateTime.now(), inputEntry.dateTime))
//        .toList();
//
//    return StreamBuilder<Object>(
//      stream: InputHoursUpdater.ihu.updateStream$,
//      builder: (context, snapshot) {
//        return ListView.builder(
//            itemCount: DataStorageHelper().categoryNames.length + 1,
//            itemBuilder: (context, index) {
//              double value = 0.0;
//              if (index == DataStorageHelper().categoryNames.length)
//                return SizedBox(height: 100);
//
//              for (final inputEntries in todayEntries) {
//                if (inputEntries.inputType ==
//                    DataStorageHelper().categories[index])
//                  value += inputEntries.amount;
//              }
//              return GlobalProgressWidget(
//                  DataStorageHelper().categories[index], value);
//            });
//      }
//    );
//  }
//}
