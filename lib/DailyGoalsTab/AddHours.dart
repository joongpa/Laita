import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miatracker/Models/DataStorageHelper.dart';
import 'package:miatracker/Models/InputEntry.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';
import '../Map.dart' as constants;
import 'DatePicker.dart';

class AddHours extends StatefulWidget {
  @override
  _AddHoursState createState() => _AddHoursState();
}

class _AddHoursState extends State<AddHours> {
  NumberFormat f = NumberFormat("#");
  DateTime dateTime;
  double hours = 0.0;
  double minutes = 0.0;
  String description = "";
  bool buttonDisabled = true;

  List<bool> _selections;
  int _selectedIndex = 0;

  @override
  void initState(){
    super.initState();
    _selections = List.generate(DataStorageHelper().categoryNames.length, (index) => false);
    _selections[0] = true;
    dateTime = DateTime.now();
  }

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
              DatePicker(
                selectedDate: dateTime,
                onChanged: (dt) {
                  setState((){
                    dateTime = dt;
                    if(constants.sameDay(dt, DateTime.now())){
                      final duration = Duration(hours: DateTime.now().hour, minutes: DateTime.now().minute);
                      dateTime.add(duration);
                    }
                  });
                },
              ),
              SizedBox(
                height: 20,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ToggleButtons(
                  children: List.generate(_selections.length, (index) => choiceButton(DataStorageHelper().categoryNames[index])),
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
                          _selectedIndex = index;
                        } else {
                          _selections[buttonIndex] = false;
                        }
                      }
                    });
                  },
                ),
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
    InputEntry entry = InputEntry(description: description, dateTime: dateTime, inputType: DataStorageHelper().categories[_selectedIndex], amount: totalTime);
    DataStorageHelper().insertInputEntry(entry);
    Navigator.pop(context);
  }

  Widget choiceButton(String text) => Padding(
        padding: EdgeInsets.all(10.0),
        child: Text(text),
      );
}
