
import 'package:flutter/material.dart';
import 'package:miatracker/InputHoursUpdater.dart';

import 'InputLog.dart';
import 'Map.dart';
import 'StatisticsPageWidget.dart';

class StatisticsSummaryWidget extends StatefulWidget {
  @override
  _StatisticsSummaryWidgetState createState() =>
      _StatisticsSummaryWidgetState();
}

class _StatisticsSummaryWidgetState extends State<StatisticsSummaryWidget> {
  List<bool> _selections = [false, false, true];
  int timeFrame = 7;
  DateTime lastSunday;

  @override
  void initState(){
    super.initState();
    lastSunday = getLastSunday();

    InputHoursUpdater.ihu.updateStream$.listen((data) {
      if(data == 1.0) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                onPressed: (){
                  setState(() {
                    lastSunday = daysAgo(7, lastSunday);
                  });
                },
                child: Icon(
                  Icons.chevron_left,
                  size: 40,
                ),
              ),
            ),
            Expanded(
              child: Text(
                getDate(lastSunday),
                //getDate(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
            ),
            Expanded(
              child: FlatButton(
                onPressed: daysBetween(lastSunday, DateTime.now()) < 7 ? null : () {
                  setState(() {
                    lastSunday = daysAgo(-7, lastSunday);
                  });
                },
                child: Icon(
                  Icons.chevron_right,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        ToggleButtons(
          children: <Widget>[_choiceButton("Year"), _choiceButton("Month"), _choiceButton("Week")],
          borderRadius: BorderRadius.circular(5),
          selectedColor: Colors.white,
          fillColor: Colors.red,
          isSelected: _selections,
          onPressed: (int index) {
            setState(() {
              for (int buttonIndex = 0;
              buttonIndex < _selections.length;
              buttonIndex++) {
                if (buttonIndex == index) {
                  _selections[buttonIndex] = true;
                } else {
                  _selections[buttonIndex] = false;
                }
              }
              timeFrame = _selectionToTimeFrame();
            });
          },
        ),
        SizedBox(height: 20),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(
                      "Reading",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    StatisticsPageWidget(
                        inputType: InputType.Reading,
                        startDate: lastSunday,
                        endDate: daysBetween(lastSunday, DateTime.now()) < 7 ? DateTime.now() : daysAgo(-6, lastSunday)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(
                      "Listening",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    StatisticsPageWidget(
                        inputType: InputType.Listening,
                        startDate: lastSunday,
                        endDate: daysBetween(lastSunday, DateTime.now()) < 7 ? DateTime.now() : daysAgo(-6, lastSunday)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(
                      "Anki",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    StatisticsPageWidget(
                        inputType: InputType.Anki,
                        startDate: lastSunday,
                        endDate: daysBetween(lastSunday, DateTime.now()) < 7 ? DateTime.now() : daysAgo(-6, lastSunday)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _selectionToTimeFrame() {
    int i = 0;
    for(; i < _selections.length; i++) {
      if(_selections[i]) break;
    }
    switch(i) {
      case 0:
        return 365;
        break;
      case 1:
        return 35;
        break;
      case 2:
        return 7;
        break;
    }

    return 7;
  }

  Widget _choiceBoxRow() => Row(

  );

  _choiceButton(String text) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.0),
    child: Text(text),
  );

  DateTime getLastSunday() {
    for(int i = 0; i < 7; i ++) {
      final testDay = daysAgo(i);
      if(testDay.weekday == DateTime.sunday) return testDay;
    }
    return DateTime.now();
  }
}
