import 'package:flutter/material.dart';
import 'package:miatracker/Map.dart';

import '../Models/TimeFrameModel.dart';

class DateTraverser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DateTime>>(
        stream: TimeFrameModel().timeFrameStream$,
        builder: (context, snapshot) {
          final data = snapshot.data ?? [DateTime.now(), DateTime.now()];
          String shownDate = _getShownDate(data);

//          switch(TimeFrameModel().selectedTimeSpan) {
//            case TimeSpan.HalfYear:
//              final bool firstHalf = TimeFrameModel().
//              shownDate = '${()}';
//              break;
//            case TimeSpan.Month:
//              break;
//          }

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
                  onPressed: data[1].isBefore(daysAgo(0))
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
    );
  }

  String _getShownDate(List<DateTime> dates) {
    String shownDate;

    switch(TimeFrameModel().selectedTimeSpan) {
      case TimeSpan.Week:
        shownDate = 'Week of ' + getDate(dates[0]);
        break;
      case TimeSpan.Month:
        shownDate = getDate(dates[0], showDay: false);
        break;
      case TimeSpan.HalfYear:
        if(dates[0].month == 1) shownDate = '1st Half of ${dates[0].year}';
        else shownDate = '2nd Half of ${dates[0].year}';
    }

    return shownDate;
  }
}
