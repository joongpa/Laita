import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/Map.dart';
import 'package:miatracker/Models/InputEntry.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';
import 'package:miatracker/Models/TimeFrameModel.dart';
import 'package:miatracker/Models/aggregate_data_model.dart';
import 'dart:math' as math;

import 'package:miatracker/Models/category.dart';
import 'package:miatracker/Models/user.dart';
import 'package:provider/provider.dart';

class StatisticsPageWidget extends StatelessWidget {
  final Category inputType;

  StatisticsPageWidget(
      {@required this.inputType});

  @override
  Widget build(BuildContext context) {
    var timeFrames = Provider.of<List<DateTime>>(context);
    Map<DateTime, DailyInputEntry> entries = Provider.of<Map<DateTime, DailyInputEntry>>(context);

    final countedDays = daysBetween(timeFrames[0], timeFrames[1]);

    double hours;
    if(entries.length == 0)
      hours = 0.0;
    else hours = entries.values.map<double>((e) => e.categoryHours[inputType.name] ?? 0).reduce((a,b) => a + b);
    String value = convertToStatsDisplay(hours / countedDays, inputType.isTimeBased);
    return _getWidget(value);
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
            'per day',
            style: TextStyle(color: Colors.grey, fontSize: 15)),
      ],
    );
  }
}
