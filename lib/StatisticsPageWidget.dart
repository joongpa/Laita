import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/DataStorageHelper.dart';
import 'package:miatracker/InputHoursUpdater.dart';
import 'package:miatracker/InputLog.dart';
import 'package:miatracker/Map.dart';

class StatisticsPageWidget extends StatelessWidget {
  final InputType inputType;
  final DateTime startDate;
  final DateTime endDate;

  StatisticsPageWidget(
      {@required this.inputType,
        @required this.startDate,
        @required this.endDate});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DataStorageHelper().getTotalHoursInput(inputType, startDate, endDate),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: UsefulShit.convertToTime((snapshot.data) / (daysBetween(startDate, endDate) + 1)),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text: '\nhrs/day',
                        style: TextStyle(color: Colors.grey, fontSize: 15)),
                  ],
                ),
              ),
            ],
          );
        } else return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: "0:00",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                ),
                children: <TextSpan>[
                  TextSpan(
                      text: '\nhrs/day',
                      style: TextStyle(color: Colors.grey, fontSize: 15)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
