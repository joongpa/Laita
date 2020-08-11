import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';
import 'package:miatracker/Models/TimeFrameModel.dart';
import 'package:miatracker/Models/aggregate_data_model.dart';
import 'package:miatracker/Models/user.dart';
import 'package:provider/provider.dart';
import '../Models/user.dart' as model;
import '../Models/InputEntry.dart';
import '../Map.dart';

class InputSeries {
  DateTime day;
  double hours;

  InputSeries({@required this.day, @required this.hours});

  void add(double hours) {
    this.hours += hours;
  }
}

class InputChart extends StatelessWidget {
  final bool isTimeBased;
  final customTickFormatter = charts.BasicNumericTickFormatterSpec((num value) {
    final isHalfHour = (value / 4) % 1 != 0;
    return isHalfHour ? '' : '${convertToDisplay(value / 4)}';
  });

  final List<bool> choiceArray;

  final List<List<InputSeries>> inputSeriesList = List<List<InputSeries>>(8);

  InputChart({@required this.choiceArray, this.isTimeBased = true});

  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppUser>(context);
    List<DateTime> dateTimes = Provider.of<List<DateTime>>(context);
    Map<DateTime, DailyInputEntry> entries =
        Provider.of<Map<DateTime, DailyInputEntry>>(context);
    if (user == null) return Container();

    List<model.Category> categories = user.categories
        .where((element) => element.isTimeBased == isTimeBased)
        .toList();

    List<charts.Series<InputSeries, DateTime>> series = [];

    for (int i = categories.length - 1; i >= 0; i--) {
      if (choiceArray[i]) {
        inputSeriesList[i] = [];
        for (int j = 0; j < daysBetween(dateTimes[0], dateTimes[1]); j++) {
          double hours = 0;
          if (entries[daysAgo(-j, dateTimes[0])] != null &&
              entries[daysAgo(-j, dateTimes[0])]
                      .categoryHours[categories[i].name] !=
                  null) {
            hours = math.max(0, entries[daysAgo(-j, dateTimes[0])]
                .categoryHours[categories[i].name]);
            hours *= (categories[i].isTimeBased) ? 4 : 1;
          }
          inputSeriesList[i]
              .add(InputSeries(day: daysAgo(-j, dateTimes[0]), hours: hours));
        }

        series.add(charts.Series(
            id: categories[i].name,
            data: inputSeriesList[i],
            domainFn: (InputSeries series, _) => series.day,
            measureFn: (InputSeries series, _) => series.hours,
            colorFn: (_, __) =>
                charts.ColorUtil.fromDartColor(categories[i].color)));
      }
    }
    if (series.length == 0) return Container();

    return charts.TimeSeriesChart(
      series,
      animate: false,
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickFormatterSpec: isTimeBased ? customTickFormatter : null,
        tickProviderSpec: charts.BasicNumericTickProviderSpec(
            desiredTickCount: getTicksFromMaxValue(series), dataIsInWholeNumbers: true),
      ),
    );
  }

  int getTicksFromMaxValue(List<charts.Series<InputSeries, DateTime>> entryList) {
    final maxValue = entryList.map((series) => series.data.map((e) => e.hours).reduce(math.max)).reduce(math.max);
    int ticks = (maxValue / 2).ceil() + 1;

    if (ticks >= 17)
      ticks = ((ticks - 1) / 2).round() + 1;
    else if (ticks % 2 == 0) ticks++;

    return math.max(5, ticks);
  }
}
