import 'package:flutter/material.dart';
import 'package:miatracker/Models/category.dart';
import 'package:miatracker/Models/shared_preferences.dart';
import 'package:miatracker/Models/user.dart';
import 'package:provider/provider.dart';

import 'InputSeries.dart';

class FullGraphWidget extends StatefulWidget {
  final bool isTimeBased;

  FullGraphWidget({this.isTimeBased = true});

  @override
  _FullGraphWidgetState createState() => _FullGraphWidgetState();
}

class _FullGraphWidgetState extends State<FullGraphWidget> {
  List<bool> _choiceBoxValues = List.generate(8, (i) => true);

  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppUser>(context);
    var pref = Provider.of<SharedPreferencesHelper>(context);
    if (user == null || user.categories == null || user.categories.length == 0) return Container();

    List<Category> categories = user.categories
        .where((element) => element.isTimeBased == widget.isTimeBased)
        .toList();

    categories = categories
        .where((category) =>
            !category.isCompleted ||
            pref.showCompletedCategoriesInGraph)
        .toList();

    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Flexible(
          child: Wrap(
        runSpacing: -15,
        spacing: 0,
        alignment: WrapAlignment.center,
        children: List.generate(
          categories.length,
          (i) => Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Checkbox(
                visualDensity: VisualDensity.compact,
                activeColor: categories[i].color,
                value: _choiceBoxValues[i],
                onChanged: (bool) {
                  setState(() {
                    _choiceBoxValues[i] = bool;
                  });
                },
              ),
              Container(
                  width: 50,
                  child: Text(
                    categories[i].name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 13),
                  )),
            ],
          ),
        ),
      )),
      Flexible(
        flex: 3,
        child: Padding(
          padding: const EdgeInsets.only(right: 25),
          child: Container(
            height: 250,
            width: 360,
            child: InputChart(
              choiceArray: _choiceBoxValues,
              isTimeBased: widget.isTimeBased,
            ),
            //decoration: BoxDecoration(color: Colors.grey),
          ),
        ),
      ),
    ]);
  }
}
