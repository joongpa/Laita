import 'dart:math' as math;

import 'package:charts_flutter/flutter.dart' as charts;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/DataStorageHelper.dart';
import 'package:miatracker/StatsTab/TimeFrameModel.dart';

import '../InputEntry.dart';
import '../Map.dart';

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

  final List<bool> choiceArray;
  final List<Color> colorArray;

  final List<double> _maxValue = [0];

  InputChart({
    @required this.choiceArray,
    this.colorArray
  });


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: TimeFrameModel().timeFrameStream$,
      builder: (context, snapshot) {
        final data = snapshot.data ?? [DateTime.now(), DateTime.now()];
        return FutureBuilder<List<InputEntry>>(
            future: DataStorageHelper()
                .getInputEntriesFor(data[0], data[1]),
            builder: (context, snapshot2) {
              if (snapshot2.hasData) {
                _maxValue[0] = 0;
                List<charts.Series<InputSeries, String>> series = [];

                for(int i = choiceArray.length-1; i >= 0; i--) {
                  if (choiceArray[i]) {
                    List<InputSeries> tempList = _formatData(
                        snapshot2.data.where((inputEntry) => inputEntry.inputType == DataStorageHelper().categories[i]).toList(), data);

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
    );
  }

  List<InputSeries> _formatData(List<InputEntry> list, List data) {
    List<InputSeries> tempList;

    switch(TimeFrameModel().selectedTimeSpan){
      case TimeSpan.Week:
        tempList = List<InputSeries>.generate(
          7,
          (i) =>
              InputSeries(day: getDay(daysAgo(-i, data[0]).weekday), hours: 0));
        break;

      case TimeSpan.Month:
        final length = 5;
        tempList = List<InputSeries>.generate(
            length,
            (i) => InputSeries(day: '${getDate(daysAgo(-i * 7, data[0]), showYear: false)}-${getDate(daysAgo((-i-1) * 7 + 1, data[0]), showYear: false, showMonth: (i == length - 1))}', hours: 0));
        for (final inputEntry in list) {
          final tempDate = inputEntry.dateTime;
          for (int i = 0; i < tempList.length; i ++) {
            if (tempDate.isAfter(daysAgo(-i * 7, data[0])) && tempDate.isBefore(daysAgo((-i-1) * 7, data[0]))) {
              tempList[i].add(4 * inputEntry.duration / 6);
            }
          }
        }
        //_maxValue[0] = tempList.map<double>((i) => i.hours/4).toList().reduce(math.max);
        return tempList;
        break;

      case TimeSpan.HalfYear:
        tempList = List<InputSeries>.generate(6,
                (i) =>
                InputSeries(day: getMonth(monthsAgo(-i, data[0]).month), hours: 0));
        for (final inputEntry in list) {
          final tempDate = inputEntry.dateTime;
          for (int i = 0; i < tempList.length; i++) {
            final monthStart = monthsAgo(-i, data[0]);
            final monthEnd = monthsAgo(-(i+1), data[0]);

            if ((tempDate.isAtSameMomentAs(monthStart) || tempDate.isAfter(monthStart)) && tempDate.isBefore(monthEnd)) {
              final monthLength = daysBetween(monthStart, monthEnd);
              tempList[i].add(4 * inputEntry.duration / (monthLength));
            }
          }
        }
        //_maxValue[0] = tempList.map<double>((i) => i.hours/4).toList().reduce(math.max);
        return tempList;
        break;
    }
    for (final inputEntry in list) {
      final tempDate = inputEntry.dateTime;
      for (int i = 0; i < tempList.length; i++) {
        if (sameDay(daysAgo(-i, data[0]), tempDate)) {
          tempList[i].add(4 * inputEntry.duration);
        }
      }
    }
    //_maxValue[0] = tempList.map<double>((i) => i.hours/4).toList().reduce(math.max);
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
