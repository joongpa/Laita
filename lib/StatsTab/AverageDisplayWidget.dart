import 'package:flutter/material.dart';
import 'package:miatracker/Models/category.dart';
import 'package:miatracker/Models/shared_preferences.dart';
import 'package:miatracker/Models/user.dart';
import 'package:miatracker/StatsTab/SingleAccuracyWidget.dart';
import 'package:provider/provider.dart';

import 'StatisticsPageWidget.dart';

class AverageDisplayWidget extends StatelessWidget {
  AverageDisplayWidget();

  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppUser>(context);
    var pref = Provider.of<SharedPreferencesHelper>(context);
    if (user == null || user.categories == null || user.categories.length == 0)
      return Container();

    var incompleteCategories = user.categories
        .where((category) =>
            !category.isCompleted ||
            pref.showCompletedCategoriesInGraph)
        .toList();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 5,
      runSpacing: 20,
      children: List.generate(incompleteCategories.length, (index) {
        return Column(
          children: <Widget>[
            Container(
              width: 80,
              child: Text(
                incompleteCategories[index].name,
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
              inputType: incompleteCategories[index],
            ),
            const SizedBox(height: 5),
            SingleAccuracyWidget(
              inputType: incompleteCategories[index],
            ),
          ],
        );
      }),
    );
  }
}
