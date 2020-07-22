import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miatracker/DataStorageHelper.dart';
import 'package:miatracker/Lifecycle.dart';
import 'package:miatracker/Map.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'InputHoursUpdater.dart';

class GlobalProgressWidget extends StatefulWidget {
  final Category inputType;

  GlobalProgressWidget(this.inputType);

  @override
  _GlobalProgressWidgetState createState() => _GlobalProgressWidgetState();
}

class _GlobalProgressWidgetState extends State<GlobalProgressWidget> {
  final f = new NumberFormat('0.0');

  double value = 0;

  @override
  void initState() {
    super.initState();
    InputHoursUpdater.ihu.updateStream$.listen((data) {
      _updateProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
      child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              Text(
                widget.inputType.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Text(
                          UsefulShit.convertToTime(value),
                          style: TextStyle(fontSize: 30.0),
                        ),
                        const Divider(
                          height: 2,
                          thickness: 2,
                          color: Colors.grey,
                          indent: 0,
                          endIndent: 0,
                        ),
                        Text(
                          UsefulShit.convertToTime(DataStorageHelper().getGoalOfInput(widget.inputType) ?? 0.0),
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "  Hrs",
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(
                    width: 17,
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: LinearPercentIndicator(
                        lineHeight: 20.0,
                        percent: _getPercent(value, DataStorageHelper().getGoalOfInput(widget.inputType)),
                        linearStrokeCap: LinearStrokeCap.roundAll,
                        progressColor: _getPercent(value, DataStorageHelper().getGoalOfInput(widget.inputType)) == 1.0
                            ? Colors.green
                            : Colors.blue,
                        backgroundColor: Color.fromRGBO(237, 237, 237, 1),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  _getPercent(double num, double dom) {
    if(num < 0 || dom < 0) return 0.0;
    if(num == null) num = 0;
    if(dom == null) dom = 0;
    if(dom == 0.0) return 0.0;
    return (num > dom) ? 1.0 : num/dom;
  }

  _updateProgress() {
    DataStorageHelper().calculateInputToday(widget.inputType).then((data) {
      setState(() {
        value = data;
      });
    });
  }
}
