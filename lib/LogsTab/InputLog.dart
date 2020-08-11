import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miatracker/LogsTab/ConfirmDialog.dart';
import 'package:miatracker/Models/Entry.dart';
import 'package:miatracker/Models/GoalEntry.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';
import 'package:miatracker/Models/category.dart';
import 'package:miatracker/Models/database.dart';
import 'package:provider/provider.dart';
import '../Models/user.dart';

import '../Models/InputEntry.dart';
import '../Map.dart';

class InputLog extends StatelessWidget {
  final durationFormat = NumberFormat("0.0");
  final DateTime dateTime;

  InputLog({this.dateTime});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser>(context);
    if(user == null) return Container();

    return FutureBuilder<List<Entry>>(
      future: DatabaseService.instance.getEntriesOnDay(user, dateTime),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());

        return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              if(index >= snapshot.data.length) return Container();

              final entry = snapshot.data[index];

              String subtitleText = '';
              if (entry is InputEntry) {
                subtitleText = entry.description;
              }
              final goalText = "Set daily goal to ";

              if (entry is GoalEntry) {
                return Card(
                    child: Container(
                      color: Color.fromRGBO(235, 235, 235, 1),
                      child: ListTile(
                        subtitle: Text(subtitleText),
                        leading: Text(
                          entry.inputType,
                          style: TextStyle(
                            color: Color.fromRGBO(140, 140, 140, 1),
                          ),
                        ),
                        title: Text(
                          '$goalText${convertToDisplay(entry.amount, categoryFromName(entry.inputType, user.categories).isTimeBased)}',
                          style: TextStyle(
                            color: Color.fromRGBO(140, 140, 140, 1),
                          ),
                        ),
                        trailing: Text(
                          entry.time,
                          style: TextStyle(
                            color: Color.fromRGBO(140, 140, 140, 1),
                          ),
                        ),
                      ),
                    ));
              }

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
                  return await asyncConfirmDialog(context, title: "Confirm Delete", description: 'Delete entry? This action cannot be undone');
                },
                onDismissed: (dis) {
                  DatabaseService.instance.deleteInputEntry(user, entry);
                },
                child: Card(
                    child: ListTile(
                      subtitle: Text(subtitleText),
                      leading: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            entry.inputType,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            color: categoryFromName(entry.inputType, user.categories).color,
                            width: 40,
                            height: 10
                          )
                        ],
                      ),
                      title: Text('${convertToDisplay(entry.amount, categoryFromName(entry.inputType, user.categories).isTimeBased)}'),
                      trailing: Text(entry.time),
                    )),
              );
            });
      }
    );
  }
}
