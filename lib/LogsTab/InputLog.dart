import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miatracker/Models/DataStorageHelper.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';

import '../Models/InputEntry.dart';
import '../Map.dart';

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
                    child: const Icon(
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
