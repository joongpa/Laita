import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';
import 'package:miatracker/Map.dart';
import 'package:miatracker/Models/aggregate_data_model.dart';
import 'package:miatracker/Models/category.dart';
import 'package:miatracker/Models/database.dart';
import 'package:provider/provider.dart';
import '../Models/user.dart';
import 'GlobalProgressWidget.dart';

class ProgressListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AppUser>(context);
    var dailyInputEntry = Provider.of<Map<DateTime, DailyInputEntry>>(context);

    if (user == null) return Container();

    return ListView.builder(
        itemCount: user.categories.length + 1,
        itemBuilder: (context, index) {
          if (index == user.categories.length)
            return SizedBox(height: 100);

          if (dailyInputEntry == null || dailyInputEntry[daysAgo(0)] == null)
            return GlobalProgressWidget(
              name: user.categories[index].name,
              isTimeBased: user.categories[index].isTimeBased,
              value: 0.0,
              goal: user.categories[index].goalAmount ?? 0.0,
            );
          return GlobalProgressWidget(
            goal: user.categories[index].goalAmount ?? 0.0,
            value: dailyInputEntry[daysAgo(0)].categoryHours[user.categories[index].name] ?? 0.0,
            isTimeBased: user.categories[index].isTimeBased,
            name: user.categories[index].name,
          );
        });

  }
}
