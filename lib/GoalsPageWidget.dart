import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/Models/DataStorageHelper.dart';

import 'Map.dart';

class GoalsPageWidget extends StatefulWidget {
  @override
  _GoalsPageWidgetState createState() => _GoalsPageWidgetState();
}

class _GoalsPageWidgetState extends State<GoalsPageWidget> {

  Map<Category, TextEditingController> controllersMap;

  @override
  void initState() {
    super.initState();
    final inputTypes = List.generate(DataStorageHelper().categoryNames.length, (i) => DataStorageHelper().categories[i]);
    final controllers = List.generate(DataStorageHelper().categoryNames.length, (i) => TextEditingController());
    controllersMap = Map.fromIterables(inputTypes, controllers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daily Target"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: ListView.builder(
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
                          controller: controllersMap[DataStorageHelper().categories[index]],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Hours per day',
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    RaisedButton(
                      child: Text("Cancel"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    RaisedButton(
                      child: Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        controllersMap.forEach((k,v) {
                          try {
                            final value = double.tryParse(v.text);
                            if(value != null) {
                              DataStorageHelper().setGoalOfInput(k, value);
                            }
                          } on FormatException {
                            print("get yeeted on by doubles");
                          }
                        });
                        Navigator.pop(context);
                      },
                      color: Colors.blue,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controllersMap.forEach((k, v) {
      v.dispose();
    });
    super.dispose();
  }
}
