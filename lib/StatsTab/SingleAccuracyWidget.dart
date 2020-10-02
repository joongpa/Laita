import 'package:flutter/material.dart';
import 'package:miatracker/Models/DailyInputEntryPacket.dart';
import 'package:miatracker/Models/GoalEntry.dart';
import 'package:miatracker/Models/InputEntry.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';
import 'package:miatracker/Models/TimeFrameModel.dart';
import 'package:miatracker/Models/aggregate_data_model.dart';
import 'package:miatracker/Models/category.dart';
import 'package:miatracker/Models/shared_preferences.dart';
import 'package:miatracker/Models/user.dart';
import 'package:provider/provider.dart';

import '../Map.dart';

class SingleAccuracyWidget extends StatelessWidget {
  final Category inputType;

  SingleAccuracyWidget({@required this.inputType});

  @override
  Widget build(BuildContext context) {
    final entries = Provider.of<DailyInputEntryPacket>(context);
    final pref = Provider.of<SharedPreferencesHelper>(context);

    if (entries == null ||
        entries.dailyInputEntries == null) return Container();

    var countedDays = daysBetween(entries.startDate, entries.endDate);
    countedDays = readjustTimeFrame(countedDays);

    var successes = entries.dailyInputEntries.values.toSet().where((element) {
      try {
        return roundTo2Decimals(element.categoryHours[inputType.name].toDouble()) >=
                inputType.goalAmount &&
            element.categoryHours[inputType.name] != 0;
      } catch (e) {
        return false;
      }
    });

    String value;
    String denom = '% ';
    double fontSize = 20;
    if (pref.showAccuracyAsFraction) {
      value = '${successes.length}';
      denom = '/$countedDays';
      fontSize = 50 / denom.length;
    } else
      value =
          (100 * successes.length.toDouble() / countedDays).round().toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              value,
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
              ),
            ),
            Text(denom,
                style: TextStyle(color: Colors.grey, fontSize: fontSize)),
          ],
        ),
        Text('met goal', style: TextStyle(color: Colors.grey, fontSize: 15)),
      ],
    );
  }
}
