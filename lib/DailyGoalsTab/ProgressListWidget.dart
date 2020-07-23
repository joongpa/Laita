import 'package:flutter/material.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';
import 'package:miatracker/Map.dart';

import '../Models/DataStorageHelper.dart';
import '../Models/InputEntry.dart';
import 'GlobalProgressWidget.dart';

class ProgressListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<InputEntry>>(
      stream: InputHoursUpdater.ihu.dbChangesStream$,
      builder: (context, snapshot) {
        List<InputEntry> todayEntries = [];
        if(snapshot.hasData)
            todayEntries = snapshot.data.where((inputEntry) => sameDay(DateTime.now(), inputEntry.dateTime)).toList();

        return ListView.builder(
            itemCount: DataStorageHelper().categoryNames.length + 1,
            itemBuilder: (context, index) {
              double value = 0.0;
              if(index == DataStorageHelper().categoryNames.length) return SizedBox(height: 100);

              for(final inputEntries in todayEntries) {
                if(inputEntries.inputType == DataStorageHelper().categories[index])
                  value += inputEntries.duration;
              }
              return GlobalProgressWidget(DataStorageHelper().categories[index], value);
            }
        );
      }
    );
  }
}

    
    