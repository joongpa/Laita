import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miatracker/Models/InputEntry.dart';
import 'package:miatracker/Models/category.dart';
import 'package:miatracker/Models/database.dart';
import 'dart:math' as math;
import '../Map.dart' as constants;
import 'DatePicker.dart';
import '../Models/user.dart';

class AddHours extends StatefulWidget {

  final AppUser user;
  final List<Category> categories;
  final int initialSelectionIndex;

  AddHours(this.user, this.categories, {this.initialSelectionIndex = 0});

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
  Category _selectedCategory;

  @override
  void initState() {
    super.initState();
    try {
      _selectedCategory = widget.categories[widget.initialSelectionIndex];
      _selections = List.generate(8, (index) {
        if(index == widget.initialSelectionIndex) return true;
        return false;
      });
    } catch (e) {
    }
    dateTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedCategory == null) {
      return Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text("Woops!"),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Text(
                'To log your input, go to the "Goals" page under the drawer menu and add a new category. Good luck on your language learning journey!',
                style: TextStyle(
                  fontSize: 20
                ),),
            ),
          )
      );
    }
    return Scaffold(
      resizeToAvoidBottomPadding: false,
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
                  setState(() {
                    dateTime = dt;
                    if (constants.sameDay(dt, DateTime.now())) {
                      final duration = Duration(hours: DateTime
                          .now()
                          .hour, minutes: DateTime
                          .now()
                          .minute);
                      dateTime.add(duration);
                    }
                  });
                },
              ),
              SizedBox(
                height: 20,
              ),
              if(widget.categories.length != 0)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ToggleButtons(
                    children: List.generate(widget.categories.length, (index) =>
                        choiceButton(widget.categories[index].name)),
                    borderRadius: BorderRadius.circular(10),
                    selectedColor: Colors.white,
                    fillColor: Colors.red,
                    isSelected: _selections.sublist(
                        0, widget.categories.length),
                    onPressed: (int index) {
                      setState(() {
                        for (int buttonIndex = 0;
                        buttonIndex < _selections.length;
                        buttonIndex++) {
                          if (buttonIndex == index) {
                            _selections[buttonIndex] = true;
                            _selectedCategory = widget.categories[index];
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
              if(_selectedCategory.isTimeBased)...
              [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 20),
                          children: <TextSpan>[
                            TextSpan(
                                text: f.format(math.min(6, hours)),
                                style: TextStyle(fontSize: 25)),
                            TextSpan(text: " hrs")
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Slider(
                        value: math.min(6, hours),
                        min: 0,
                        max: 6,
                        onChanged: (newValue) {
                          setState(() {
                            hours = newValue;
                            if (newValue != 0)
                              buttonDisabled = false;
                            else if (minutes == 0 && hours == 0)
                              buttonDisabled = true;
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
                            if (newValue != 0)
                              buttonDisabled = false;
                            else if (minutes == 0 && hours == 0)
                              buttonDisabled = true;
                          });
                        },
                        divisions: 11,
                        onChangeEnd: (double) {},
                      ),
                    ),
                  ],
                ),
              ],
              if(!_selectedCategory.isTimeBased)...[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 20),
                          children: <TextSpan>[
                            TextSpan(
                                text: hours.round().toString(),
                                style: TextStyle(fontSize: 25)),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Slider(
                        value: hours,
                        min: 0,
                        max: 20,
                        onChanged: (newValue) {
                          setState(() {
                            hours = newValue;
                            if (newValue != 0)
                              buttonDisabled = false;
                            else if (minutes == 0 && hours == 0)
                              buttonDisabled = true;
                          });
                        },
                        divisions: 20,
                        onChangeEnd: (double) {},
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(
                height: 20,
              ),
              _submitButton(widget.user, widget.categories),
            ],
          ),
        ),
      ),
    );
  }

  Widget _submitButton(AppUser user, List<Category> categories) =>
      RaisedButton(
        child: Text(
          "Done",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onPressed: buttonDisabled ? null : () =>
            _buttonAction(user, categories),
        color: Colors.lightBlue,
      );

  _buttonAction(AppUser user, List<Category> categories) {
    double totalTime = hours + ((_selectedCategory.isTimeBased) ? minutes / 60 : 0);
    InputEntry entry = InputEntry(description: description,
        dateTime: dateTime,
        inputType: _selectedCategory.name,
        amount: totalTime);
    DatabaseService.instance.addInputEntry(user, entry);
    Navigator.pop(context);
  }

  Widget choiceButton(String text) =>
      Padding(
        padding: EdgeInsets.all(10.0),
        child: Text(text),
      );
}
