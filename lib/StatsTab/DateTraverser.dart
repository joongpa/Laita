import 'package:flutter/material.dart';
import 'package:miatracker/Map.dart';
import 'package:provider/provider.dart';

import '../Models/TimeFrameModel.dart';

class DateTraverser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var timeFrameModel = Provider.of<TimeFrameModel>(context);
    final dateStartEndTimes = timeFrameModel.dateStartEndTimes;
    String shownDate = _getShownDate(dateStartEndTimes);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: FlatButton(
            onPressed: () {
              TimeFrameModel().shiftTimeFramePast();
            },
            child: const Icon(
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
            onPressed: dateStartEndTimes[1].isBefore(daysAgo(-1, daysAgo(0)))
                ? () {
              TimeFrameModel().shiftTimeFrameFuture();
            } : null,
            child: const Icon(
              Icons.chevron_right,
              size: 40,
            ),
          ),
        ),
      ],
    );
  }

  String _getShownDate(List<DateTime> dates) {
    String shownDate;

    switch(TimeFrameModel().selectedTimeSpan) {
      case TimeSpan.Week:
        shownDate = '${getDate(dates[0], showYear: false)} - ${getDate(daysAgo(1, dates[1]), showYear: false)}';
        break;
      case TimeSpan.Month:
        shownDate = '${getDate(dates[0], showYear: false)} - ${getDate(daysAgo(1, dates[1]), showYear: false)}';
        break;
      case TimeSpan.HalfYear:
        shownDate = '${getDate(dates[0], showDay: false)} - ${getDate(daysAgo(1, dates[1]), showDay: false)}';
    }

    return shownDate;
  }
}
