import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/Models/DataStorageHelper.dart';
import 'package:miatracker/Models/GoalEntry.dart';
import 'dart:math' as math;
import 'package:miatracker/Models/InputHoursUpdater.dart';
import 'package:miatracker/Models/database.dart';
import 'package:miatracker/Models/category.dart';
import 'package:provider/provider.dart';

import 'LogsTab/ConfirmDialog.dart';

class GoalsPageWidget extends StatefulWidget {
  @override
  _GoalsPageWidgetState createState() => _GoalsPageWidgetState();
}

class _GoalsPageWidgetState extends State<GoalsPageWidget> {
  Map<Category, TextEditingController> controllersMap;
  TextEditingController _newCategoryDialogController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    if(user == null) return Container();

    return StreamBuilder<List<Category>>(
      stream: DatabaseService.instance.categoriesStream(user),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return Container();

        final inputTypes = List.generate(snapshot.data.length,
                (i) => snapshot.data[i]);
        final controllers = List.generate(snapshot.data.length,
                (i) => TextEditingController());
        controllersMap = Map.fromIterables(inputTypes, controllers);

        return Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text("Daily Target"),
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                flex: 6,
                child: ListView.builder(
                  itemCount:
                      math.min(snapshot.data.length + 1, 8),
                  itemBuilder: (context, index) {
                    if (index == snapshot.data.length) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FlatButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.add,
                                color: Colors.grey,
                              ),
                              Text(
                                "Add New Category",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          onPressed: () async {
                            String name = await _displayDialog(context);
                            if (name != null && name != '')
                              DatabaseService.instance.addCategory(user, Category(name: name, dateTime: DateTime.now()));
                          },
                        ),
                      );
                    }
                    return Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
                      child: Dismissible(
                        direction: DismissDirection.endToStart,
                        background: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          alignment: AlignmentDirectional.centerEnd,
                          color: Colors.red,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await asyncConfirmDialog(context,
                              title: 'Confirm Delete',
                              description:
                                  'Delete category? Logs of this category will remain but will not be visible in the home page or graphs.');
                        },
                        onDismissed: (direction) async {
                          DatabaseService.instance.deleteCategory(user, snapshot.data[index]);
                        },
                        key: UniqueKey(),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                "Daily ${snapshot.data[index].name} Target",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: controllersMap[
                                snapshot.data[index]],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Hours per day',
                                ),
                              ),
                            ),
                          ],
                        ),
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
                            controllersMap.forEach((k, v) {
                              try {
                                final value = double.tryParse(v.text);
                                if (value != null) {
                                  DatabaseService.instance.addGoalEntry(user, GoalEntry.now(inputType: k.name, amount: value));
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
    );
  }

  @override
  void dispose() {
    controllersMap.forEach((k, v) {
      v.dispose();
    });
    super.dispose();
  }

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add New Category'),
            content: TextField(
              controller: _newCategoryDialogController,
              decoration: InputDecoration(hintText: "Name of category"),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(_newCategoryDialogController.text);
                  _newCategoryDialogController.clear();
                },
              )
            ],
          );
        });
  }
}
