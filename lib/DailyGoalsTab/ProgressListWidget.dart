import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:miatracker/Map.dart';
import 'package:miatracker/Models/aggregate_data_model.dart';
import 'package:provider/provider.dart';
import '../Models/user.dart';
import 'GlobalProgressWidget.dart';

class ProgressListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AppUser>(context);
    var dailyInputEntry = Provider.of<Map<DateTime, DailyInputEntry>>(context);

    if (user == null || user.categories == null || user.categories.length == 0) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 10,
            right: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Go to 'Categories' to add a new category\n(e.g. Reading, Listening, etc)",
                  textAlign: TextAlign.right,
                ),
                SizedBox(width: 10),
                Icon(
                  Icons.arrow_upward,
                  size: 40,
                ),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Welcome to LAITA!', style: TextStyle(fontSize: 20),),
                  SizedBox(height: 10),
                  Text("Once you've added a category, you'll be able to view your daily progress on this page as well as add new logs."),
                ],
              ),
            ),
          ),
        ],
      );
    }

    var incompleteCategories =
        user.categories.where((category) => !category.isCompleted).toList();

    return ListView.builder(
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
            value: dailyInputEntry[daysAgo(0)]
                    .categoryHours[incompleteCategories[index].name] ??
                0.0,
            category: incompleteCategories[index],
            index: index,
          );
        });
  }
}
