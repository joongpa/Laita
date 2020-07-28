import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:miatracker/Models/GoalEntry.dart';
import 'package:miatracker/Models/InputEntry.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';
import 'package:miatracker/Models/TimeFrameModel.dart';
import 'package:provider/provider.dart';

import '../Map.dart';

class SingleAccuracyWidget extends StatelessWidget {
  final Category inputType;

  SingleAccuracyWidget(
      {@required this.inputType});

  @override
  Widget build(BuildContext context) {
    final providedTimeFrame = Provider.of<List<DateTime>>(context);
    final providedGoalList = Provider.of<List<GoalEntry>>(context);
    final providedInputList = Provider.of<List<InputEntry>>(context);

    if(providedTimeFrame == null || providedGoalList == null || providedInputList == null)
      return Container();

    DateTime realEndDate = providedTimeFrame[1];
    if(realEndDate.isAfter(daysAgo(-1, DateTime.now()))) {
      realEndDate = daysAgo(-1, DateTime.now());
    }

    final goals = Filter.goalsPerDay(providedGoalList, category: this.inputType, startDate: providedTimeFrame[0], endDate: realEndDate);
    final hours = Filter.totalInputPerDay(providedInputList, category: this.inputType, startDate: providedTimeFrame[0], endDate: realEndDate);
    int passCount = 0;
    int failCount = 0;

    for(int i = 0; i < goals.length; i++) {
      if(goals[i] == 0 && hours[i] == 0) {
        failCount++;
        continue;
      }
      passCount += (hours[i] >= goals[i]) ? 1 : 0;
      failCount += (hours[i] < goals[i]) ? 1 : 0;
    }

    if(passCount + failCount == 0) return _getWidget("0");
    String value = (100 * passCount.toDouble() / (passCount + failCount)).round().toString();
    return _getWidget(value);
  }

  Widget _getWidget(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
              ),
            ),
            Text(
                '%',
                style: TextStyle(color: Colors.grey, fontSize: 20)),
          ],
        ),
        Text(
            'met goal',
            style: TextStyle(color: Colors.grey, fontSize: 15)),
      ],
    );
  }
}