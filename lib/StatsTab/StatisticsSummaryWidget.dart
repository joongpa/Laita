import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/Models/DataStorageHelper.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';
import 'package:miatracker/StatsTab/AccuracyDisplayWidget.dart';
import 'package:miatracker/StatsTab/AverageDisplayWidget.dart';
import 'package:miatracker/StatsTab/FullGraphWidget.dart';
import 'package:miatracker/StatsTab/SingleAccuracyWidget.dart';
import 'package:miatracker/StatsTab/TimeFramePicker.dart';
import 'DateTraverser.dart';

class StatisticsSummaryWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: InputHoursUpdater.ihu.updateStream$,
      builder: (context, snapshot) {
        return ListView(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[300],
                    blurRadius: 5.0, // has the effect of softening the shadow
                    spreadRadius: 2.0, // has the effect of extending the shadow
                    offset: Offset(
                      1.0, // horizontal, move right 10
                      1.0, // vertical, move down 10
                    ),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FullGraphWidget(),
                    DateTraverser(),
                    SizedBox(height: 5),
                    TimeFramePicker(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: AverageDisplayWidget(),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: AccuracyDisplayWidget(),
            ),
          ],
        );
      }
    );
  }

}
