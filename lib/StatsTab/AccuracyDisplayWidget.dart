import 'package:flutter/material.dart';
import 'package:miatracker/Models/category.dart';
import 'package:miatracker/StatsTab/SingleAccuracyWidget.dart';
import 'package:provider/provider.dart';


class AccuracyDisplayWidget extends StatelessWidget {
  AccuracyDisplayWidget();

  @override
  Widget build(BuildContext context) {
    var categories = Provider.of<List<Category>>(context) ?? [];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 25,
      runSpacing: 20,
      children:
      List.generate(categories.length, (index) {
        return SingleAccuracyWidget(
          inputType: categories[index],
        );
      }),
    );
  }
}
