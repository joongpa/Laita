import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miatracker/Models/DataStorageHelper.dart';
import 'package:miatracker/Map.dart';
import 'package:percent_indicator/percent_indicator.dart';

class GlobalProgressWidget extends StatelessWidget {
  final Category inputType;
  final double value;
  final f = new NumberFormat('0.0');

  GlobalProgressWidget(this.inputType, this.value);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
      child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              Text(
                inputType.name,
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
                          convertToTime(value),
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
                          convertToTime(DataStorageHelper().getGoalOfInput(inputType) ?? 0.0),
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    "  Hrs",
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(
                    width: 17,
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: LinearPercentIndicator(
                        lineHeight: 20.0,
                        percent: _getPercent(value, DataStorageHelper().getGoalOfInput(inputType)),
                        linearStrokeCap: LinearStrokeCap.roundAll,
                        progressColor: _getPercent(value, DataStorageHelper().getGoalOfInput(inputType)) == 1.0
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
}
