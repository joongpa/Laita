import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/Models/DataStorageHelper.dart';
import 'package:miatracker/Models/GoalEntry.dart';
import 'package:miatracker/Models/InputEntry.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';
import 'package:miatracker/Models/TimeFrameModel.dart';
import 'package:miatracker/StatsTab/AccuracyDisplayWidget.dart';
import 'package:miatracker/StatsTab/AverageDisplayWidget.dart';
import 'package:miatracker/StatsTab/FullGraphWidget.dart';
import 'package:miatracker/StatsTab/SingleAccuracyWidget.dart';
import 'package:miatracker/StatsTab/TimeFramePicker.dart';
import 'package:provider/provider.dart';
import 'DateTraverser.dart';

class StatisticsSummaryWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<List<DateTime>>.value(
            value: TimeFrameModel().timeFrameStream$
        )
      ],
      child: StreamBuilder(
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
                child: Container(
                  height: 420,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                          child: PageView(
                            children: <Widget>[
                              FullGraphWidget(isTimeBased: true,),
                              FullGraphWidget(isTimeBased: false,),
                            ],
                          ),
                        ),
                        DateTraverser(),
                        TimeFramePicker(),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: AverageDisplayWidget(),
              ),
              const SizedBox(height: 15),
            ],
          );
        }
      ),
    );
  }

}
