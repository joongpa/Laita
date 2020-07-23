import 'package:flutter/material.dart';

import 'TimeFrameModel.dart';

class TimeFramePicker extends StatefulWidget {
  @override
  _TimeFramePickerState createState() => _TimeFramePickerState();
}

class _TimeFramePickerState extends State<TimeFramePicker> {
  List<bool> _selections = [false, false, true];
  int selectedIndex = 2;
  
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.8,
      child: ToggleButtons(
        children: <Widget>[
          _choiceButton(TimeSpan.HalfYear.name),
          _choiceButton(TimeSpan.Month.name),
          _choiceButton(TimeSpan.Week.name)
        ],
        borderRadius: BorderRadius.circular(30),
        selectedColor: Colors.white,
        fillColor: Colors.red,
        isSelected: _selections,
        onPressed: (int index) {
          setState(() {
            for (int buttonIndex = 0;
            buttonIndex < _selections.length;
            buttonIndex++) {
              if (buttonIndex == index) {
                selectedIndex = index;
                _selections[buttonIndex] = true;
              } else {
                _selections[buttonIndex] = false;
              }
            }
          });
          TimeFrameModel().selectedTimeSpan = _indexToTimeSpan(selectedIndex);
        },
      ),
    );
  }

  _choiceButton(String text) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 40.0),
    child: Text(text, style: TextStyle(
      fontSize: 18,
    ),),
  );

  TimeSpan _indexToTimeSpan(int index) {
    switch(index) {
      case 0:
        return TimeSpan.HalfYear;
        break;
      case 1:
        return TimeSpan.Month;
        break;
      case 2:
        return TimeSpan.Week;
        break;
    }

    return TimeSpan.Week;
  }
}
