
import 'package:flutter/material.dart';
import 'package:miatracker/Models/GoalEntry.dart';
import 'package:miatracker/Models/InputEntry.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';
import 'package:miatracker/Models/TimeFrameModel.dart';
import 'package:miatracker/Models/aggregate_data_model.dart';
import 'package:miatracker/Models/category.dart';
import 'package:miatracker/Models/user.dart';
import 'package:provider/provider.dart';

import '../Map.dart';

class SingleAccuracyWidget extends StatelessWidget {
  final Category inputType;

  SingleAccuracyWidget(
      {@required this.inputType});

  @override
  Widget build(BuildContext context) {
    final providedTimeFrame = Provider.of<TimeFrameModel>(context);
    final entries = Provider.of<Map<DateTime,DailyInputEntry>>(context);

    if(providedTimeFrame == null || entries == null)
      return Container();

    DateTime realEndDate = providedTimeFrame.dateStartEndTimes[1];
    if(realEndDate.isAfter(daysAgo(-1, DateTime.now()))) {
      realEndDate = daysAgo(-1, DateTime.now());
    }
    int passCount = 0;
    int failCount = 0;

    for(int i = 0; i < daysBetween(providedTimeFrame.dateStartEndTimes[0], providedTimeFrame.dateStartEndTimes[1]); i++) {
      try {
        if(entries[daysAgo(-i, providedTimeFrame.dateStartEndTimes[0])].categoryHours[inputType.name] == 0 && entries[daysAgo(-i, providedTimeFrame.dateStartEndTimes[0])].goalAmounts[inputType.name] == 0) {
          failCount++;
          continue;
        }
        passCount += (entries[daysAgo(-i, providedTimeFrame.dateStartEndTimes[0])].categoryHours[inputType.name] >= entries[daysAgo(-i, providedTimeFrame.dateStartEndTimes[0])].goalAmounts[inputType.name]) ? 1 : 0;
        failCount += (entries[daysAgo(-i, providedTimeFrame.dateStartEndTimes[0])].categoryHours[inputType.name] < entries[daysAgo(-i, providedTimeFrame.dateStartEndTimes[0])].goalAmounts[inputType.name]) ? 1 : 0;
      } catch (e) {
        failCount++;
      }
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