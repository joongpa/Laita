import 'package:flutter/material.dart';
import 'package:miatracker/Map.dart';
import 'package:miatracker/Models/aggregate_data_model.dart';
import 'package:miatracker/Models/shared_preferences.dart';
import 'package:miatracker/Models/user.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class LifetimeAmountDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppUser>(context);
    DailyInputEntry firstEntry = Provider.of<DailyInputEntry>(context);
    var pref = Provider.of<SharedPreferencesHelper>(context);
    if (user == null || user.categories == null || user.categories.length == 0) return Container();

    var incompleteCategories = user.categories
        .where((category) =>
    !category.isCompleted ||
        pref.showCompletedCategoriesInLifetimeSummary)
        .toList();

    DateTime startDate;
    if(firstEntry == null)
      startDate = DateTime.fromMillisecondsSinceEpoch(0);
    else startDate = firstEntry.dateTime;

    return Column(
      children: [
        Wrap(
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
                _getWidget(_convertToDisplay(
                    math.max(0,incompleteCategories[index].lifetimeAmount),
                    incompleteCategories[index].isTimeBased),
                    incompleteCategories[index].isTimeBased),
              ],
            );
          }),
        ),
        SizedBox(height: 15),
        Row(
          children: [
            Expanded(
                child: Text(
              'Start Date',
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.grey),
            )),
            SizedBox(width: 10),
            Expanded(
              child: Text(getDate(startDate)),
            )
          ],
        )
      ],
    );
  }

  String _convertToDisplay(double value, bool isTimeBased) {
    if (isTimeBased) {
      return (value >= 100)
          ? value.toInt().toString()
          : UsefulShit.singleDecimalFormat.format(value);
    } else {
      return value.toInt().toString();
    }
  }

  Widget _getWidget(String text, bool isTimeBased) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
          ),
        ),
        Text(isTimeBased ? 'hours' : 'amount',
            style: TextStyle(color: Colors.grey, fontSize: 15)),
      ],
    );
  }
}
