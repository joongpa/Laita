import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/Models/DataStorageHelper.dart';
import 'package:miatracker/Map.dart';
import 'package:miatracker/Models/InputEntry.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';
import 'package:miatracker/Models/TimeFrameModel.dart';
import 'dart:math' as math;

import 'package:miatracker/Models/category.dart';
import 'package:provider/provider.dart';

class StatisticsPageWidget extends StatelessWidget {
  final Category inputType;

  StatisticsPageWidget(
      {@required this.inputType});

  @override
  Widget build(BuildContext context) {
    var inputEntries = Provider.of<List<InputEntry>>(context) ?? [];

    return StreamBuilder(
      stream: TimeFrameModel().timeFrameStream$,
      builder: (context, stream) {
        if (stream.hasData) {
          final countedDays = math.min(TimeFrameModel().selectedTimeSpan.value, daysBetween(stream.data[0], DateTime.now()) + 1);
          final hours = Filter.getTotalInput(inputEntries, category: this.inputType, startDate: stream.data[0], endDate: stream.data[1]);
          String value = convertToDisplay(hours / countedDays, inputType.isTimeBased);
          return _getWidget(value);
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
            'per day',
            style: TextStyle(color: Colors.grey, fontSize: 15)),
      ],
    );
  }
}
