import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miatracker/DataStorageHelper.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'InputHoursUpdater.dart';

class GlobalProgressWidget extends StatelessWidget {
  final f = new NumberFormat('0.0');
  final String inputType;
  final double value;
  final Stream stream;

  GlobalProgressWidget(this.inputType, this.value, this.stream);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
      child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              Text(
                inputType,
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
                          f.format(value ?? 0),
                          style: TextStyle(fontSize: 30.0),
                        ),
                        const Divider(
                          height: 2,
                          thickness: 2,
                          color: Colors.grey,
                          indent: 0,
                          endIndent: 0,
                        ),
                        StreamBuilder(
                            stream: stream,
                            builder: (context, snapshot) {
                              return Text(
                                f.format(snapshot.data ?? 0.0),
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.grey,
                                ),
                              );
                            }),
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
                        percent: ((value ?? 0.0) / 3.0 > 1.0)
                            ? 1.0
                            : (value ?? 0.0) / 3.0,
                        linearStrokeCap: LinearStrokeCap.roundAll,
                        progressColor: ((value ?? 0.0) / 3.0 >= 1.0)
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
}
