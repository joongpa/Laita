import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:miatracker/Models/GoalEntry.dart';
import 'package:miatracker/Models/InputEntry.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';
import 'package:miatracker/Models/TimeFrameModel.dart';

import '../Map.dart';

class SingleAccuracyWidget extends StatelessWidget {
  final Category inputType;

  SingleAccuracyWidget(
      {@required this.inputType});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: TimeFrameModel().timeFrameStream$,
        builder: (context, stream) {
          if (stream.hasData) {
            DateTime realEndDate = stream.data[1];

            if(realEndDate.isAfter(daysAgo(-1, DateTime.now()))) {
              realEndDate = daysAgo(-1, DateTime.now());
            }

            return StreamBuilder<List<GoalEntry>>(
              stream: InputHoursUpdater.ihu.goalDbChangesStream$,
              builder: (context, goalSnapshot)  {
                if(!goalSnapshot.hasData) return _getWidget("0.0%");

                final goals = Filter.goalsPerDay(goalSnapshot.data, category: this.inputType, startDate: stream.data[0], endDate: realEndDate);


                return StreamBuilder<List<InputEntry>>(
                  stream: InputHoursUpdater.ihu.dbChangesStream$,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final hours = Filter.totalInputPerDay(snapshot.data, category: this.inputType, startDate: stream.data[0], endDate: realEndDate);
                      int passCount = 0;
                      int failCount = 0;

                      for(int i = 0; i < goals.length; i++) {
                        if(goals[i] == 0 && hours[i] == 0) continue;
                        passCount += (hours[i] >= goals[i]) ? 1 : 0;
                        failCount += (hours[i] < goals[i]) ? 1 : 0;
                      }
                      if(passCount + failCount == 0) return _getWidget("0.0");
                      String value = UsefulShit.singleDecimalFormat.format(100 * passCount.toDouble() / (passCount + failCount));
                      return _getWidget(value);
                    }
                    else return _getWidget("0:00");
                  },
                );
              },
            );
          } else return _getWidget("0:00");
        }
    );
  }

  Widget _getWidget(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
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
            style: TextStyle(color: Colors.grey, fontSize: 15)),
      ],
    );
  }
}