import 'package:flutter/material.dart';
import 'package:miatracker/Models/TimeFrameModel.dart';
import 'package:miatracker/StatsTab/SingleAccuracyWidget.dart';

import '../Models/DataStorageHelper.dart';
import '../Map.dart';
import 'StatisticsPageWidget.dart';

class AccuracyDisplayWidget extends StatelessWidget {
  AccuracyDisplayWidget();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 25,
      runSpacing: 20,
      children:
      List.generate(DataStorageHelper().categoryNames.length, (index) {
        return SingleAccuracyWidget(
          inputType: DataStorageHelper().categories[index],
        );
      }),
    );
  }
}
