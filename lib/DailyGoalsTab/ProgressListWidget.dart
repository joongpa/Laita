import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';
import 'package:miatracker/Map.dart';
import 'package:miatracker/Models/category.dart';
import 'package:miatracker/Models/database.dart';
import 'package:provider/provider.dart';

import '../Models/DataStorageHelper.dart';
import '../Models/InputEntry.dart';
import 'GlobalProgressWidget.dart';

class ProgressListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var categories = Provider.of<List<Category>>(context) ?? [];
    var inputEntries = Provider.of<List<InputEntry>>(context) ?? [];

    return ListView.builder(
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if(index == categories.length) return SizedBox(height: 100);
          double value = Filter.getTotalInput(inputEntries, category: categories[index], startDate: daysAgo(0, DateTime.now()), endDate: daysAgo(-1, DateTime.now()));
          return GlobalProgressWidget(categories[index], value);
        }
    );
  }
}

    
    