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
  final List<double> _maxValue = [0];

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
            _maxValue[0] = 0;
            List<charts.Series<InputSeries, String>> series = [];

            for(int i = choiceArray.length-1; i >= 0; i--) {
              if (choiceArray[i]) {
                List<InputSeries> tempList = _formatData(
                    snapshot.data.where((inputEntry) => inputEntry.inputType == DataStorageHelper().categories[i]).toList());

                series.add(charts.Series(
                  id: DataStorageHelper().categoryNames[i],
                  data: tempList,
                  domainFn: (InputSeries series, _) => series.day,
                  measureFn: (InputSeries series, _) => series.hours,
                  colorFn: (_, __) =>
                      charts.ColorUtil.fromDartColor(colorArray[i]),
                ));
              }
            }

            return charts.BarChart(
              series,
              animate: false,
              barGroupingType: charts.BarGroupingType.stacked,
              primaryMeasureAxis: charts.NumericAxisSpec(
                tickFormatterSpec: customTickFormatter,
                tickProviderSpec: charts.BasicNumericTickProviderSpec(/*desiredTickCount: getTicksFromMaxValue(),*/ dataIsInWholeNumbers: true),
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
        _maxValue[0] = tempList.map<double>((i) => i.hours/4).toList().reduce(math.max);
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
        _maxValue[0] = tempList.map<double>((i) => i.hours/4).toList().reduce(math.max);
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
    _maxValue[0] = tempList.map<double>((i) => i.hours/4).toList().reduce(math.max);
    return tempList;
  }

//  int getTicksFromMaxValue(List<charts.Series<InputSeries, String>> entryList) {
//    List<double> doubleList= [0,0,0];
//
//    for(int i = 0; i < entryList.length; i++) {
//      if(entryList[i].) {
//        for(int j = 0; j < entryList[j].length; j++){
//          doubleList[i] += entryList[j][i].hours;
//        }
//      }
//    }
//    _maxValue[0] = math.max(_maxValue[0], doubleList.reduce(math.max));
//    return math.max(5, _maxValue[0].ceil() + 1);
//  }
}
