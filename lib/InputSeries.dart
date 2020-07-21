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
  charts.BasicNumericTickFormatterSpec((num value) => '${UsefulShit.convertToTime(value/2)}');
  final DateTime startDate;
  final DateTime endDate;
  final List<bool> choiceArray;
  final List<Color> colorArray;
  final int timeFrame;

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
            List<InputSeries> tempList1 = _formatData(snapshot.data.where((inputEntry) => inputEntry.inputType == InputType.Reading).toList());
            List<InputSeries> tempList2 = _formatData(snapshot.data.where((inputEntry) => inputEntry.inputType == InputType.Listening).toList());
            List<InputSeries> tempList3 = _formatData(snapshot.data.where((inputEntry) => inputEntry.inputType == InputType.Anki).toList());

            List<charts.Series<InputSeries, String>> series = [];

            if(choiceArray[2])
              series.add(charts.Series(
                id: "Anki",
                data: tempList3,
                domainFn: (InputSeries series, _) => series.day,
                measureFn: (InputSeries series, _) => series.hours,
                colorFn: (_, __) => charts.ColorUtil.fromDartColor(colorArray[2]),
              ));

            if(choiceArray[1])
              series.add(charts.Series(
                id: "Listening",
                data: tempList2,
                domainFn: (InputSeries series, _) => series.day,
                measureFn: (InputSeries series, _) => series.hours,
                colorFn: (_, __) => charts.ColorUtil.fromDartColor(colorArray[1]),
              ));

            if(choiceArray[0])
              series.add(charts.Series(
                id: "Reading",
                data: tempList1,
                domainFn: (InputSeries series, _) => series.day,
                measureFn: (InputSeries series, _) => series.hours,
                colorFn: (_, __) => charts.ColorUtil.fromDartColor(colorArray[0]),
              ));

            return charts.BarChart(
              series,
              animate: false,
              barGroupingType: charts.BarGroupingType.stacked,
              primaryMeasureAxis: charts.NumericAxisSpec(
                tickFormatterSpec: customTickFormatter,
                tickProviderSpec: charts.BasicNumericTickProviderSpec(desiredMinTickCount: 12, desiredMaxTickCount: 12, dataIsInWholeNumbers: true),
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
              tempList[i].add(2 * inputEntry.duration / 6);
            }
          }
        }
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
              tempList[i].add(2 * inputEntry.duration / (monthLength));
            }
          }
        }

        return tempList;
        break;
    }

    for (final inputEntry in list) {
      final tempDate = inputEntry.dateTime;
      for (int i = 0; i < tempList.length; i++) {
        if (sameDay(daysAgo(-i, startDate), tempDate)) {
          tempList[i].add(2 * inputEntry.duration);
        }
      }
    }

    return tempList;
  }
}
