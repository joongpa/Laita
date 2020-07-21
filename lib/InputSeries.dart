import 'dart:math' as math;

import 'package:charts_flutter/flutter.dart' as charts;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/DataStorageHelper.dart';

import 'InputEntry.dart';
import 'Map.dart';

class InputSeries {
  String day;
  double hours;

  InputSeries({@required this.day, @required this.hours});

  void add(double hours) {
    this.hours += hours;
  }
}

class InputChart extends StatelessWidget {
  final customTickFormatter =
  charts.BasicNumericTickFormatterSpec((num value) => '${UsefulShit.convertToTime(value/4)}');
  final DateTime startDate;
  final DateTime endDate;
  final List<bool> choiceArray;
  final List<Color> colorArray;
  final int timeFrame;
  double _maxValue = 0;

  InputChart({
    @required this.startDate,
    @required this.endDate,
    @required this.choiceArray,
    @required this.timeFrame,
    this.colorArray
  });


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<InputEntry>>(
        future: DataStorageHelper()
            .getInputEntriesFor(startDate, endDate),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _maxValue = 0;
            List<charts.Series<InputSeries, String>> series = [];

            if(choiceArray[2]) {
              List<InputSeries> tempList3 = _formatData(
                  snapshot.data.where((inputEntry) => inputEntry.inputType ==
                      InputType.Anki).toList());
              series.add(charts.Series(
                id: "Anki",
                data: tempList3,
                domainFn: (InputSeries series, _) => series.day,
                measureFn: (InputSeries series, _) => series.hours,
                colorFn: (_, __) =>
                    charts.ColorUtil.fromDartColor(colorArray[2]),
              ));
            }

            if(choiceArray[1]){
              List<InputSeries> tempList2 = _formatData(snapshot.data.where((inputEntry) => inputEntry.inputType == InputType.Listening).toList());
              series.add(charts.Series(
                id: "Listening",
                data: tempList2,
                domainFn: (InputSeries series, _) => series.day,
                measureFn: (InputSeries series, _) => series.hours,
                colorFn: (_, __) => charts.ColorUtil.fromDartColor(colorArray[1]),
              ));
            }


            if(choiceArray[0]) {
              List<InputSeries> tempList1 = _formatData(snapshot.data.where((inputEntry) => inputEntry.inputType == InputType.Reading).toList());
              series.add(charts.Series(
                id: "Reading",
                data: tempList1,
                domainFn: (InputSeries series, _) => series.day,
                measureFn: (InputSeries series, _) => series.hours,
                colorFn: (_, __) => charts.ColorUtil.fromDartColor(colorArray[0]),
              ));
            }

            return charts.BarChart(
              series,
              animate: false,
              barGroupingType: charts.BarGroupingType.stacked,
              primaryMeasureAxis: charts.NumericAxisSpec(
                tickFormatterSpec: customTickFormatter,
                tickProviderSpec: charts.BasicNumericTickProviderSpec(desiredTickCount: 5, dataIsInWholeNumbers: true),
              ),
            );
          } else
            return Container();
        });
  }

  List<InputSeries> _formatData(List<InputEntry> list) {

    List<InputSeries> tempList;

    switch(timeFrame){
      case 2:
        tempList = List<InputSeries>.generate(
          7,
          (i) =>
              InputSeries(day: getDay(daysAgo(-i, startDate).weekday), hours: 0));
        break;

      case 1:
        final length = 5;
        tempList = List<InputSeries>.generate(
            length,
            (i) => InputSeries(day: '${getDate(daysAgo(-i * 7, startDate), showYear: false)}-${getDate(daysAgo((-i-1) * 7 + 1, startDate), showYear: false, showMonth: (i == length - 1))}', hours: 0));
        for (final inputEntry in list) {
          final tempDate = inputEntry.dateTime;
          for (int i = 0; i < tempList.length; i ++) {
            if (tempDate.isAfter(daysAgo(-i * 7, startDate)) && tempDate.isBefore(daysAgo((-i-1) * 7, startDate))) {
              tempList[i].add(4 * inputEntry.duration / 6);
            }
          }
        }
        _maxValue = tempList.map<double>((i) => i.hours/4).toList().reduce(math.max);
        return tempList;
        break;

      case 0:
        tempList = List<InputSeries>.generate(6,
                (i) =>
                InputSeries(day: getMonth(monthsAgo(-i, startDate).month), hours: 0));

        for (final inputEntry in list) {
          final tempDate = inputEntry.dateTime;
          for (int i = 0; i < tempList.length; i++) {
            final monthStart = monthsAgo(-i, startDate);
            final monthEnd = monthsAgo(-(i+1), startDate);

            if ((tempDate.isAtSameMomentAs(monthStart) || tempDate.isAfter(monthStart)) && tempDate.isBefore(monthEnd)) {
              final monthLength = daysBetween(monthStart, monthEnd);
              tempList[i].add(4 * inputEntry.duration / (monthLength));
            }
          }
        }
        _maxValue = tempList.map<double>((i) => i.hours/4).toList().reduce(math.max);
        return tempList;
        break;
    }

    for (final inputEntry in list) {
      final tempDate = inputEntry.dateTime;
      for (int i = 0; i < tempList.length; i++) {
        if (sameDay(daysAgo(-i, startDate), tempDate)) {
          tempList[i].add(4 * inputEntry.duration);
        }
      }
    }
    _maxValue = tempList.map<double>((i) => i.hours/4).toList().reduce(math.max);

    return tempList;
  }

//  int getTicksFromMaxValue(List<List<InputSeries>> entryList) {
//    List<double> doubleList= [0,0,0];
//
//    for(int i = 0; i < entryList.length; i++) {
//      if(entryList[i].isNotEmpty) {
//        for(int j = 0; j < entryList[j].length; j++){
//          doubleList[i] += entryList[j][i].hours;
//        }
//      }
//    }
//    _maxValue = math.max(_maxValue, doubleList.reduce(math.max));
//    return math.max(5, _maxValue.ceil() + 1);
//  }
}
