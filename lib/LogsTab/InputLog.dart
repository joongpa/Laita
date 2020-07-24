import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miatracker/LogsTab/ConfirmDialog.dart';
import 'package:miatracker/Models/DataStorageHelper.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';

import '../Models/InputEntry.dart';
import '../Map.dart';

class InputLog extends StatelessWidget {
  final durationFormat = NumberFormat("0.0");
  final DateTime dateTime;

  InputLog({this.dateTime});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: StreamBuilder<List<InputEntry>>(
            stream: InputHoursUpdater.ihu.dbChangesStream$,
            builder: (context, snapshot) {
              if(!snapshot.hasData) return Container();

              final List<InputEntry> inputEntries = Filter.filterEntries(snapshot.data, startDate: dateTime, endDate: daysAgo(-1, dateTime));

              return ListView.builder(
                itemCount: inputEntries.length,
                itemBuilder: (context, index) {
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
                    confirmDismiss: (disDirection) async {
                      return await asyncConfirmDialog(context);
                    },
                    onDismissed: (dis) {
                      DataStorageHelper().deleteInputEntry(inputEntries[index].id);
                    },
                    child: Card(
                        child: ListTile(
                          subtitle: Text(inputEntries[index].description),
                          leading: Text(inputEntries[index].inputType.name),
                          title: Text(
                              '${convertToTime(inputEntries[index].duration)}'),
                          trailing: Text(inputEntries[index].time),
                        )),
                  );
                }
              );
            }
          ),
        ),
      ],
    );
  }
}


