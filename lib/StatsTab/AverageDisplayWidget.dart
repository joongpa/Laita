import 'package:flutter/material.dart';
import 'package:miatracker/Models/TimeFrameModel.dart';
import 'package:miatracker/Models/category.dart';
import 'package:miatracker/StatsTab/SingleAccuracyWidget.dart';
import 'package:provider/provider.dart';

import '../Models/DataStorageHelper.dart';
import '../Map.dart';
import 'StatisticsPageWidget.dart';

class AverageDisplayWidget extends StatelessWidget {
  AverageDisplayWidget();

  @override
  Widget build(BuildContext context) {
    var categories = Provider.of<List<Category>>(context) ?? [];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 0,
      runSpacing: 20,
      children:
          List.generate(categories.length, (index) {
        return Column(
          children: <Widget>[
            Container(
              width: 75,
              child: Text(
                categories[index].name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 5),
            StatisticsPageWidget(
              inputType: categories[index],
            ),
            const SizedBox(height: 5),
            SingleAccuracyWidget(
              inputType: categories[index],
            ),
          ],
        );
      }),
    );
  }
}
