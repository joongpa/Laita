import 'package:flutter/material.dart';
import 'package:miatracker/Models/category.dart';
import 'package:miatracker/Models/user.dart';
import 'package:miatracker/StatsTab/SingleAccuracyWidget.dart';
import 'package:provider/provider.dart';


class AccuracyDisplayWidget extends StatelessWidget {
  AccuracyDisplayWidget();

  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppUser>(context);
    if(user == null) return Container();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 25,
      runSpacing: 20,
      children:
      List.generate(user.categories.length, (index) {
        return SingleAccuracyWidget(
          inputType: user.categories[index],
        );
      }),
    );
  }
}
