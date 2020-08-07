import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';
import 'package:miatracker/Map.dart';
import 'package:miatracker/Models/aggregate_data_model.dart';
import 'package:miatracker/Models/category.dart';
import 'package:miatracker/Models/database.dart';
import 'package:provider/provider.dart';

import '../Models/InputEntry.dart';
import 'GlobalProgressWidget.dart';

class ProgressListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    var categories = Provider.of<List<Category>>(context) ?? [];
    
    return StreamProvider<DailyInputEntry>(
      create: (_) => DatabaseService.instance.dailyProgressStream(user),
      catchError: (context, object) {
        return DailyInputEntry();
      },
      child: Consumer<DailyInputEntry>(
        builder: (_, value, __) {

          return ListView.builder(
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if(index == categories.length) return SizedBox(height: 100);
                if(value == null || value.categoryHours == null) return GlobalProgressWidget(categories[index], 0.0);
                return GlobalProgressWidget(categories[index], value.categoryHours[categories[index].name] ?? 0.0);
              }
          );
        }
      )
    );
  }
}

    
    