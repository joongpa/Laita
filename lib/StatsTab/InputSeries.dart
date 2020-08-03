import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/Models/DataStorageHelper.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';
import 'package:miatracker/Models/TimeFrameModel.dart';
import 'package:provider/provider.dart';
import '../Models/category.dart' as cat;
import '../Models/InputEntry.dart';
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
  charts.BasicNumericTickFormatterSpec((num value) {
    final isHalfHour = (value/4) % 1 != 0;
    return isHalfHour ? '' : '${convertToTime(value/4)}';
  });

  final List<bool> choiceArray;
  final List<Color> colorArray;

  final List<List<InputSeries>> inputSeriesList = List<List<InputSeries>>(8);

  InputChart({
    @required this.choiceArray,
    this.colorArray
  });

  @override
  Widget build(BuildContext context) {
    var categories = Provider.of<List<cat.Category>>(context) ?? [];
    var inputEntries = Provider.of<List<InputEntry>>(context) ?? [];

    return StreamBuilder(
      stream: TimeFrameModel().timeFrameStream$,
      builder: (context, snapshot) {
        final data = snapshot.data ?? [DateTime.now(), DateTime.now()];
        final dataList = Filter.filterEntries(inputEntries, startDate: data[0], endDate: data[1]);
        List<charts.Series<InputSeries, String>> series = [];

        for(int i = categories.length-1; i >= 0; i--) {
          if (choiceArray[i]) {
            inputSeriesList[i] = _formatData(
                dataList.where((inputEntry) => inputEntry.inputType == categories[i].name).toList(), data);

            series.add(charts.Series(
              id: categories[i].name,
              data: inputSeriesList[i],
              domainFn: (InputSeries series, _) => series.day,
              measureFn: (InputSeries series, _) => series.hours,
              colorFn: (_, __) => charts.ColorUtil.fromDartColor(colorArray[i]))
            );
          }
        }
        return charts.BarChart(
          series,
          animate: false,
          barGroupingType: charts.BarGroupingType.stacked,
          primaryMeasureAxis: charts.NumericAxisSpec(
            tickFormatterSpec: customTickFormatter,
            tickProviderSpec: charts.BasicNumericTickProviderSpec(desiredTickCount: getTicksFromMaxValue(inputSeriesList), dataIsInWholeNumbers: true),
          ),
        );
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
            (i) {
              final date1 = daysAgo(-i * 7, data[0]);
              final date2 = daysAgo((-i-1) * 7 + 1, data[0]);
              bool showSecondMonth = !sameMonth(date1, date2);
              return InputSeries(day: '${getDate(date1, showYear: false)}-${getDate(date2, showYear: false, showMonth: showSecondMonth)}', hours: 0);
            });
        for (final inputEntry in list) {
          final tempDate = inputEntry.dateTime;
          for (int i = 0; i < tempList.length; i ++) {
            if (tempDate.isAfter(daysAgo(-i * 7, data[0])) && tempDate.isBefore(daysAgo((-i-1) * 7, data[0]))) {
              tempList[i].add(4 * inputEntry.amount / 6);
            }
          }
        }

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
              tempList[i].add(4 * inputEntry.amount / (monthLength));
            }
          }
        }

        return tempList;
        break;
    }
    for (final inputEntry in list) {
      final tempDate = inputEntry.dateTime;
      for (int i = 0; i < tempList.length; i++) {
        if (sameDay(daysAgo(-i, data[0]), tempDate)) {
          tempList[i].add(4 * inputEntry.amount);
        }
      }
    }

    return tempList;
  }

  int getTicksFromMaxValue(List<List<InputSeries>> entryList) {
    int timeInterval = 1;

    for(int i = 0; i < entryList.length; i++) {
      if(entryList[0] != null) {
        timeInterval = entryList[0].length;
        break;
      }
    }

    List<double> doubleList= List.generate(timeInterval, (i) => 0);

    for(int i = 0; i < timeInterval; i++) {
      for(int j = 0; j < entryList.length; j++){
        if(entryList[j] != null)
          doubleList[i] += entryList[j][i].hours;
      }
    }
    double result = doubleList.reduce(math.max);
    int ticks = (result/2).ceil() + 1;

    if(ticks >= 17)
      ticks = ((ticks-1)/2).round() + 1;
    else if(ticks % 2 == 0)
      ticks++;

    return math.max(5, ticks);
  }
}
