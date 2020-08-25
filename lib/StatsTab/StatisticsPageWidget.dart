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
    var entries = Provider.of<Map<DateTime, DailyInputEntry>>(context);
    if(entries == null || entries.length == 0) return Center(child: CircularProgressIndicator());

    var dates = entries.keys.toList();
    dates.sort();

    var countedDays = daysBetween(dates.first, dates.last);
    countedDays = readjustTimeFrame(countedDays);

    double hours;
    if(entries.length == 0)
      hours = 0.0;
    else hours = entries.values.where((e) => e != null).map<double>((e) => (e.categoryHours[inputType.name] ?? 0)).reduce((a,b) => a + b);
    String value = convertToStatsDisplay(hours / countedDays, inputType.isTimeBased);
    Color color = (hours/countedDays >= inputType.goalAmount) ? Colors.green[800] : Colors.red[900];
    return _getWidget(value, color);
  }

  Widget _getWidget(String text, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          text,
          style: TextStyle(
            color: color,
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
