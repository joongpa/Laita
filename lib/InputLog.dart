import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miatracker/DataStorageHelper.dart';
import 'package:miatracker/InputHoursUpdater.dart';
import 'package:sqflite/sqflite.dart';

import 'InputEntry.dart';
import 'Map.dart';

class InputLog extends StatefulWidget {
  final DateTime dateTime;

  InputLog({@required this.dateTime});

  @override
  _InputLogState createState() => _InputLogState();
}

class _InputLogState extends State<InputLog> {
  List<InputEntry> inputList;

  NumberFormat durationFormat = NumberFormat("0.0");

  @override
  void initState() {
    super.initState();
    inputList = List<InputEntry>();
    _updateList();
    InputHoursUpdater.ihu.updateStream$.listen((data) {
      if(sameDay(DateTime.now(), widget.dateTime)) {
        _updateList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemCount: inputList.length,
            itemBuilder: (context, index) {
              if(sameDay(DateTime.now(), widget.dateTime)) {
                return Dismissible(
                  direction: DismissDirection.endToStart,
                  background: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    alignment: AlignmentDirectional.centerEnd,
                    color: Colors.red,
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  key: UniqueKey(),
                  onDismissed: (dis) => _dismissedCallback(index),
                  child: Card(
                      child: ListTile(
                        subtitle: Text(inputList[index].description),
                        leading: Text(inputList[index].inputType.name),
                        title: Text(
                            '${UsefulShit.convertToTime(inputList[index].duration)}'),
                        trailing: Text(inputList[index].time),
                      )),
                );
              }
              return Card(
                  child: ListTile(
                    subtitle: Text(inputList[index].description),
                    leading: Text(inputList[index].inputType.name),
                    title: Text(
                        '${UsefulShit.convertToTime(inputList[index].duration)}'),
                    trailing: Text(inputList[index].time),
                  ));
            },
          ),
        ),
      ],
    );
  }


  void _delete(InputEntry inputEntry) async {
    int result = await DataStorageHelper().deleteInputEntry(inputEntry.id);
    if (result != 0) {
      InputHoursUpdater.ihu.update();
    }
  }

  void _dismissedCallback(index) {
    _delete(inputList[index]);
    setState(() {
      inputList.removeAt(index);
    });
  }

  void _updateList() {
    final Future<List<InputEntry>> futureList =
        DataStorageHelper().getInputEntriesOnDay(widget.dateTime);
    futureList.then((list) {
      if(mounted) {
        setState(() {
          inputList = list;
        });
      }
    });
  }
}

class MultiInputLog extends StatefulWidget {
  @override
  _MultiInputLogState createState() => _MultiInputLogState();
}

class _MultiInputLogState extends State<MultiInputLog> {
  final controller = PageController(initialPage: 0);
  int page = 0;
  final daysBackViewable = 14;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.page.round() != page) {
        setState(() {
          page = controller.page.round();
        });
      }
    });
  }


  int debugInt = 0;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: InputHoursUpdater.ihu.updateStream$,
      builder: (context, snapshot) {
        return Column(
          children: <Widget>[
            Expanded(
              child: PageView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  itemCount: daysBackViewable,
                  itemBuilder: (context, page) {
                    return InputLog(dateTime: daysAgo(page));
                  }
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
                      onPressed: page == daysBackViewable - 1
                          ? null
                          : () {
                        controller.jumpToPage(controller.page.round() + 1);
                      },
                      child: Icon(
                        Icons.chevron_left,
                        size: 40,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      getDate(daysAgo(page)),
                      //getDate(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20
                      ),
                    ),
                  ),
                  Expanded(
                    child: FlatButton(
                      onPressed: page == 0
                          ? null
                          : () {
                        controller.jumpToPage(controller.page.round() - 1);
                      },
                      child: Icon(
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
      },
    );
  }
}



String getDate(DateTime date) {
  int year = date.year;
  int month = date.month;
  int day = date.day;

  Map<int,String> months = {
    1:'January',
    2:'February',
    3:'March',
    4:'April',
    5:'May',
    6:'June',
    7:'July',
    8:'August',
    9:'September',
    10:'October',
    11:'November',
    12:'December',
  };

  return '${months[month]} $day, $year';
}
