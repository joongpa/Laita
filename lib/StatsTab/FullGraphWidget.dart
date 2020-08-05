import 'package:flutter/material.dart';
import 'package:miatracker/Models/category.dart';
import 'package:provider/provider.dart';

import 'InputSeries.dart';

class FullGraphWidget extends StatefulWidget {
  final bool isTimeBased;
  FullGraphWidget({this.isTimeBased = true});

  @override
  _FullGraphWidgetState createState() => _FullGraphWidgetState();
}

class _FullGraphWidgetState extends State<FullGraphWidget> {
  List<bool> _choiceBoxValues =
      List.generate(8, (i) => true);

  List<Color> _choiceBoxColors = [
    Colors.blue,
    Colors.blueGrey,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.yellow,
    Colors.deepPurple,
    Colors.pink
  ];

  @override
  Widget build(BuildContext context) {
    var categories = Provider.of<List<Category>>(context) ?? [];
    categories = categories.where((element) => element.isTimeBased == widget.isTimeBased).toList();
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Flexible(
          child: Wrap(
        runSpacing: -20,
        spacing: 0,
        alignment: WrapAlignment.center,
        children: List.generate(
          categories.length,
          (i) => Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Checkbox(
                activeColor: _choiceBoxColors[i],
                value: _choiceBoxValues[i],
                onChanged: (bool) {
                  setState(() {
                    _choiceBoxValues[i] = bool;
                  });
                },
              ),
              Text(categories[i].name),
            ],
          ),
        ),
      )),
      Container(
        height: 250,
        width: 450,
        child: InputChart(
          choiceArray: _choiceBoxValues,
          colorArray: _choiceBoxColors,
          isTimeBased: widget.isTimeBased,
        ),
        //decoration: BoxDecoration(color: Colors.grey),
      ),
    ]);
  }
}
