

import 'package:flutter/material.dart';
import 'package:miatracker/Models/TimeFrameModel.dart';

import '../Models/DataStorageHelper.dart';
import '../Map.dart';
import 'StatisticsPageWidget.dart';

class AverageDisplayWidget extends StatelessWidget {

  AverageDisplayWidget();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: TimeFrameModel().timeFrameStream$,
      builder: (context, snapshot) {
        final data = snapshot.data ?? [DateTime.now(), DateTime.now()];
        return Wrap(
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
                const SizedBox(height: 10),
                StatisticsPageWidget(
                  inputType: DataStorageHelper().categories[index],
                  startDate: data[0],
                  endDate: data[1].isBefore(DateTime.now())
                      ? data[1]
                      : daysAgo(-1,DateTime.now()),
                ),
              ],
            );
          }),
        );
      }
    );
  }
}
