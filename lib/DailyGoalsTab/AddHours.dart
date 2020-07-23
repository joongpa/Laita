import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miatracker/Models/DataStorageHelper.dart';
import 'package:miatracker/Models/InputEntry.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';
import '../Map.dart' as constants;

class AddHours extends StatefulWidget {
  @override
  _AddHoursState createState() => _AddHoursState();
}

class _AddHoursState extends State<AddHours> {
  NumberFormat f = NumberFormat("#");
  double hours = 0.0;
  double minutes = 0.0;
  String description = "";
  bool buttonDisabled = true;

  List<bool> _selections = [true, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Immersion Entry"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 10, 10, 10),
          child: Column(
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  labelText: "Description (optional)"
                ),
                onChanged: (s) {
                  description = s;
                },
              ),
              SizedBox(
                height: 20,
              ),
              ToggleButtons(
                children: <Widget>[
                  choiceButton("Reading"),
                  choiceButton("Listening"),
                  choiceButton("   Anki   ")
                ],
                borderRadius: BorderRadius.circular(10),
                selectedColor: Colors.white,
                fillColor: Colors.red,
                isSelected: _selections,
                onPressed: (int index) {
                  setState(() {
                    for (int buttonIndex = 0;
                        buttonIndex < _selections.length;
                        buttonIndex++) {
                      if (buttonIndex == index) {
                        _selections[buttonIndex] = true;
                      } else {
                        _selections[buttonIndex] = false;
                      }
                    }
                  });
                },
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: 20),
                        children: <TextSpan>[
                          TextSpan(
                              text: f.format(hours),
                              style: TextStyle(fontSize: 25)),
                          TextSpan(text: " hrs")
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Slider(
                      value: hours,
                      min: 0,
                      max: 6,
                      onChanged: (newValue) {
                        setState(() {
                          hours = newValue;
                          if(newValue != 0) buttonDisabled = false;
                          else if(minutes == 0 && hours == 0) buttonDisabled = true;
                        });
                      },
                      divisions: 6,
                      onChangeEnd: (double) {},
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: 20),
                        children: <TextSpan>[
                          TextSpan(
                              text: f.format(minutes),
                              style: TextStyle(fontSize: 25)),
                          TextSpan(text: " min")
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Slider(
                      value: minutes,
                      min: 0,
                      max: 55,
                      onChanged: (newValue) {
                        setState(() {
                          minutes = newValue;
                          if(newValue != 0) buttonDisabled = false;
                          else if(minutes == 0 && hours == 0) buttonDisabled = true;
                        });
                      },
                      divisions: 11,
                      onChangeEnd: (double) {},
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _submitButton() => RaisedButton(
        child: Text(
          "Done",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onPressed: buttonDisabled ? null : _buttonAction,
        color: Colors.lightBlue,
      );

  _buttonAction() {
    double totalTime = hours + minutes/60;
    InputEntry entry = InputEntry.now(description: description, inputType: numToInput(), duration: totalTime);
    DataStorageHelper().insertInputEntry(entry).then((thing) {
      InputHoursUpdater.ihu.update();
    });
    Navigator.pop(context);
  }

  Widget choiceButton(String text) => Padding(
        padding: EdgeInsets.all(10.0),
        child: Text(text),
      );

  // ignore: missing_return
  constants.Category numToInput() {
    int i = 0;
    for(; i < _selections.length; i++) {
      if(_selections[i]) break;
    }
    return DataStorageHelper().categories[i];
  }
}
