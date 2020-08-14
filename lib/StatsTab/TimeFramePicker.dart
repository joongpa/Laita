import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Map.dart';
import '../Models/TimeFrameModel.dart';

class TimeFramePicker extends StatefulWidget {
  @override
  _TimeFramePickerState createState() => _TimeFramePickerState();
}

class _TimeFramePickerState extends State<TimeFramePicker> {
  List<bool> _selections = [false, false, true];
  int selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Stack(

        alignment: Alignment.centerLeft,
        children: [
          Transform.scale(
            scale: 0.7,
            alignment: Alignment.centerLeft,
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
                TimeFrameModel().selectedTimeSpan =
                    _indexToTimeSpan(selectedIndex);
              },
            ),
          ),
          Positioned(
              right: 50,
              child: FlatButton(
                shape: CircleBorder(side: BorderSide.none),
                padding: EdgeInsets.all(10),
                onPressed: () => TimeFrameModel().shiftTimeFramePast(),
                child: const Icon(Icons.chevron_left, size: 40),
              )),
          Positioned(
              right: -10,
              child: FlatButton(
                shape: CircleBorder(side: BorderSide.none),
                padding: EdgeInsets.all(10),
                onPressed: TimeFrameModel()
                        .dateStartEndTimes[1]
                        .isBefore(daysAgo(-1, daysAgo(0)))
                    ? () => TimeFrameModel().shiftTimeFrameFuture()
                    : null,
                child: const Icon(Icons.chevron_right, size: 40),
              )),
        ],
      ),
    );
  }

  _choiceButton(String text) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      );

  TimeSpan _indexToTimeSpan(int index) {
    switch (index) {
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
