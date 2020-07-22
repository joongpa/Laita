import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/InputHoursUpdater.dart';
import 'DataStorageHelper.dart';
import 'InputSeries.dart';
import 'Map.dart';
import 'StatisticsPageWidget.dart';

class StatisticsSummaryWidget extends StatefulWidget {
  @override
  _StatisticsSummaryWidgetState createState() =>
      _StatisticsSummaryWidgetState();
}

class _StatisticsSummaryWidgetState extends State<StatisticsSummaryWidget> {
  List<bool> _selections = [false, false, true];
  int selectedIndex = 2;
  List<bool> _choiceBoxValues = List.generate(DataStorageHelper().categoryNames.length, (i) => true);
  List<Color> _choiceBoxColors = [Colors.blue, Colors.blueGrey, Colors.green, Colors.orange, Colors.red, Colors.yellow];
  List<DateTime> displayDates = List<DateTime>(3);
  String shownDate;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < displayDates.length; i++) {
      displayDates[i] = _getNewStartingDate(false, DateTime.now(), index: i);
    }

    InputHoursUpdater.ihu.updateStream$.listen((data) {
      if (data == 1.0) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    switch(selectedIndex) {
      case 2:
        shownDate = 'Week of ' + getDate(displayDates[selectedIndex]);
        break;
      case 1:
        shownDate = '${getMonth(displayDates[selectedIndex].month)}, ${displayDates[selectedIndex].year}';
        break;
      case 0:
        if(displayDates[selectedIndex].month == 1) shownDate = '1st Half of ${displayDates[selectedIndex].year}';
        else shownDate = '2nd Half of ${displayDates[selectedIndex].year}';
    }
    final tempStartDate = displayDates[selectedIndex];
    final graphEndDate = daysAgo(-_selectionToTimeFrame(), tempStartDate);

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
                Flexible(
                    child: Wrap(
                  runSpacing: -20,
                  spacing: 0,
                  alignment: WrapAlignment.center,
                  children: List.generate(_choiceBoxValues.length, (i) =>
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Checkbox(
                          activeColor: _choiceBoxColors[i],
                          value: _choiceBoxValues[i],
                          onChanged: (bool) {
                            setState(() {
                              _choiceBoxValues[i] = bool;
                            });
                          },
                        ),
                        Text(DataStorageHelper().categoryNames[i]),
                      ],
                    ),
                  ),
                )),
                Container(
                  height: 250,
                  width: 450,
                  child: InputChart(
                    startDate: tempStartDate,
                    endDate: graphEndDate,
                    choiceArray: _choiceBoxValues,
                    colorArray: _choiceBoxColors,
                    timeFrame: selectedIndex,
                  ),
                  //decoration: BoxDecoration(color: Colors.grey),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: FlatButton(
                        onPressed: () {
                          setState(() {
                            displayDates[selectedIndex] = _getNewStartingDate(
                                false, displayDates[selectedIndex]);
                            //displayDate = daysAgo(7, displayDate);
                          });
                        },
                        child: Icon(
                          Icons.chevron_left,
                          size: 40,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        shownDate,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Expanded(
                      child: FlatButton(
                        onPressed: !_getNewStartingDate(
                                    true, displayDates[selectedIndex])
                                .isBefore(DateTime.now())
                            ? null
                            : () {
                                setState(() {
                                  displayDates[selectedIndex] =
                                      _getNewStartingDate(
                                          true, displayDates[selectedIndex]);
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
                SizedBox(height: 5),
                Transform.scale(
                  scale: 0.8,
                  child: ToggleButtons(
                    children: <Widget>[
                      _choiceButton("Year"),
                      _choiceButton("Month"),
                      _choiceButton("Week")
                    ],
                    borderRadius: BorderRadius.circular(30),
                    selectedColor: Colors.white,
                    fillColor: Colors.red,
                    isSelected: _selections,
                    onPressed: (int index) {
                      setState(() {
                        for (int buttonIndex = 0;
                            buttonIndex < _selections.length;
                            buttonIndex++) {
                          if (buttonIndex == index) {
                            selectedIndex = index;
                            _selections[buttonIndex] = true;
                          } else {
                            _selections[buttonIndex] = false;
                          }
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 25,
            runSpacing: 20,
            children: List.generate(DataStorageHelper().categoryNames.length, (index) {
              return Column(
                children: <Widget>[
                  Text(
                    DataStorageHelper().categoryNames[index],
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  StatisticsPageWidget(
                    inputType: DataStorageHelper().categories[index],
                    startDate: tempStartDate,
                    endDate: graphEndDate.isBefore(DateTime.now())
                        ? graphEndDate
                        : daysAgo(-1,DateTime.now()),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  int _selectionToTimeFrame() {
    switch (selectedIndex) {
      case 0:
        return 183;
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

  _choiceButton(String text) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.0),
        child: Text(text, style: TextStyle(
          fontSize: 18,
        ),),
      );

  DateTime getLastSunday() {
    for (int i = 0; i < 7; i++) {
      final testDay = daysAgo(i);
      if (testDay.weekday == DateTime.sunday) return testDay;
    }
    return DateTime.now();
  }

  DateTime getNearestSunday(
      {@required bool isForward, @required DateTime dateTime}) {
    for (int i = 1; i <= 7; i++) {
      final testDay = daysAgo(isForward ? -i : i, dateTime);
      if (testDay.weekday == DateTime.sunday) return testDay;
    }
    return DateTime.now();
  }

  DateTime monthsAgo(int months, DateTime dateTime) {
    if (dateTime.day != 1 && months > 0) months = 0;
    return DateTime(dateTime.year, dateTime.month - months, 1);
  }

  DateTime halfYearsAgo(int years, DateTime dateTime) {
    for (int i = 1; i <= 6; i++) {
      final testDay = monthsAgo(years * 6, dateTime);
      if (testDay.month == DateTime.january || testDay.month == DateTime.july)
        return testDay;
    }
    return DateTime.now();
  }

  DateTime _getNewStartingDate(bool forward, DateTime dateTime, {int index}) {
    index ??= selectedIndex;

    switch (index) {
      case 0:
        return halfYearsAgo(forward ? -1 : 1, dateTime);
        break;
      case 1:
        return monthsAgo(forward ? -1 : 1, dateTime);
        break;
      case 2:
        return getNearestSunday(isForward: forward, dateTime: dateTime);
        break;
    }
    return DateTime.now();
  }
}
