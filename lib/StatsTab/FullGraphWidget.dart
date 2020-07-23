import 'package:flutter/material.dart';
import 'package:miatracker/StatsTab/TimeFrameModel.dart';

import '../DataStorageHelper.dart';
import 'InputSeries.dart';

class FullGraphWidget extends StatefulWidget {
  FullGraphWidget();

  @override
  _FullGraphWidgetState createState() => _FullGraphWidgetState();
}

class _FullGraphWidgetState extends State<FullGraphWidget> {
  List<bool> _choiceBoxValues =
      List.generate(DataStorageHelper().categoryNames.length, (i) => true);

  List<Color> _choiceBoxColors = [
    Colors.blue,
    Colors.blueGrey,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.yellow
  ];

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Flexible(
          child: Wrap(
        runSpacing: -20,
        spacing: 0,
        alignment: WrapAlignment.center,
        children: List.generate(
          _choiceBoxValues.length,
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
              Text(DataStorageHelper().categoryNames[i]),
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
        ),
        //decoration: BoxDecoration(color: Colors.grey),
      ),
    ]);
  }
}
