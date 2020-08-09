import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:miatracker/Map.dart';
import 'package:miatracker/Models/GoalEntry.dart';
import 'package:miatracker/Models/category.dart';
import 'package:miatracker/Models/database.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

class GlobalProgressWidget extends StatelessWidget {
  final double goal;
  final double value;
  final String name;
  final bool isTimeBased;
  final f = new NumberFormat('0.0');

  GlobalProgressWidget({this.value, this.goal, this.name, this.isTimeBased});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              Text(
                name,
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
                          convertToDisplay(value, isTimeBased),
                          style: TextStyle(fontSize: 25.0),
                        ),
                        const Divider(
                          height: 2,
                          thickness: 2,
                          color: Colors.grey,
                          indent: 0,
                          endIndent: 0,
                        ),
                        Text(
                          convertToDisplay(goal, isTimeBased),
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    "  hrs",
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
                        percent: _getPercent(value, goal),
                        linearStrokeCap: LinearStrokeCap.roundAll,
                        progressColor: _getPercent(value, goal) == 1.0
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
    if(dom == 0.0 && num == 0.0) return 0.0;
    return (num > dom) ? 1.0 : num/dom;
  }
}
