import 'package:flutter/material.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';

import '../Map.dart';
import 'InputLog.dart';

class MultiInputLog extends StatefulWidget {
  @override
  _MultiInputLogState createState() => _MultiInputLogState();
}

class _MultiInputLogState extends State<MultiInputLog> {
  DateTime shownDate;

  @override
  void initState() {
    super.initState();
    shownDate = daysAgo(0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: InputLog(
            dateTime: shownDate,
          ),
        ),
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.grey[300],
                blurRadius: 5.0, // has the effect of softening the shadow
                spreadRadius: 5.0, // has the effect of extending the shadow
                offset: Offset(
                  1.0, // horizontal, move right 10
                  1.0, // vertical, move down 10
                ),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: FlatButton(
                  onPressed: () {
                    setState(() {
                      shownDate = daysAgo(1, shownDate);
                    });
                  },
                  child: const Icon(
                    Icons.chevron_left,
                    size: 40,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  getDate(shownDate),
                  //getDate(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Expanded(
                child: FlatButton(
                  onPressed: sameDay(shownDate, DateTime.now())
                      ? null
                      : () {
                          setState(() {
                            shownDate = daysAgo(-1, shownDate);
                          });
                        },
                  child: const Icon(
                    Icons.chevron_right,
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
