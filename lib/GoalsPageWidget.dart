import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/DataStorageHelper.dart';

class GoalsPageWidget extends StatefulWidget {
  @override
  _GoalsPageWidgetState createState() => _GoalsPageWidgetState();
}

class _GoalsPageWidgetState extends State<GoalsPageWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daily Target"),
      ),
      body: ListView.builder(
        itemCount: DataStorageHelper().categoryNames.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: Text(
                    "Daily ${DataStorageHelper().categoryNames[index]} Target",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Hours per day',
                    ),
                    onChanged: (s) => DataStorageHelper().setGoalOfInput(DataStorageHelper().categories[index], double.parse(s)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
