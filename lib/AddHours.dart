import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class AddHours extends StatefulWidget {
  @override
  _AddHoursState createState() => _AddHoursState();
}

class _AddHoursState extends State<AddHours> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add Hours"),
        ),
        body: Center(
            child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            GestureDetector(
              //onPanUpdate: _panHandler,
              child: CircularPercentIndicator(
                radius: 200,
                lineWidth: 30,
                percent: 0.5,
                animateFromLastPercent: true,
                animation: true,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ),
            Container(
              height: 140,
              width: 140,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              child: Center(
                child: Text(
                  '0.5',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
              ),
            )
          ],
        )));
  }
}
