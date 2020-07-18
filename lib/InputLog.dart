import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miatracker/DataStorageHelper.dart';
import 'package:miatracker/InputHoursUpdater.dart';
import 'package:sqflite/sqflite.dart';

import 'InputEntry.dart';
import 'Map.dart';

class InputLog extends StatefulWidget {
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
      _updateList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: inputList.length,
      itemBuilder: (context, index) {
        return Dismissible(
          background: Container(color: Colors.red),
          key: UniqueKey(),
          onDismissed: (direction) {
            _delete(inputList[index]);
            setState(() {
              inputList.removeAt(index);
            });
          },
          child: Card(
            child: ListTile(
              subtitle: Text(inputList[index].description),
              leading: Text(inputList[index].inputType.name),
              title: Text('${durationFormat.format(inputList[index].duration)} Hours'),
              trailing: Text(inputList[index].time),
            )
          ),
        );
      },
    );
  }

  void _delete(InputEntry inputEntry) async {
    int result = await DataStorageHelper().deleteInputEntry(inputEntry.id);
    DataStorageHelper().addInput(inputEntry.inputType, -inputEntry.duration);
    if (result != 0) {
      InputHoursUpdater.ihu.update();
    }
  }

  void _updateList() {
    final Future<List<InputEntry>> futureList = DataStorageHelper().getInputEntriesOnDay(DateTime.now());
    futureList.then((list) {
      setState(() {
        inputList = list;
      });
    });
  }
}


