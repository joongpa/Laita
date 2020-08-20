import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';
import 'package:miatracker/Map.dart';
import 'package:miatracker/Models/aggregate_data_model.dart';
import 'package:miatracker/Models/category.dart';
import 'package:miatracker/Models/database.dart';
import 'package:provider/provider.dart';
import '../Models/user.dart';
import 'AddHours.dart';
import 'GlobalProgressWidget.dart';

class ProgressListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AppUser>(context);
    var dailyInputEntry = Provider.of<Map<DateTime, DailyInputEntry>>(context);

    if (user == null || user.categories == null || user.categories.length == 0) return Container();

    var incompleteCategories = user.categories.where((category) => !category.isCompleted).toList();

    return Padding(
      padding: EdgeInsets.only(top: 12),
      child: ListView.builder(
          itemCount: incompleteCategories.length + 1,
          itemBuilder: (context, index) {
            if (index == incompleteCategories.length)
              return SizedBox(height: 100);

            if (dailyInputEntry == null || dailyInputEntry[daysAgo(0)] == null)
              return GlobalProgressWidget(
                user: user,
                value: 0.0,
                category: incompleteCategories[index],
                index: index,
              );
            return GlobalProgressWidget(
              user: user,
              value: dailyInputEntry[daysAgo(0)].categoryHours[incompleteCategories[index].name] ?? 0.0,
              category: incompleteCategories[index],
              index: index,
            );
          }),
    );

  }
}
