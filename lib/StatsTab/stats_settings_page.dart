import 'package:flutter/material.dart';
import 'package:miatracker/Models/shared_preferences.dart';

class StatsSettingsPage extends StatefulWidget {
  @override
  _StatsSettingsPageState createState() => _StatsSettingsPageState();
}

class _StatsSettingsPageState extends State<StatsSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics Preferences'),
        leading: FlatButton(
          child: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          SwitchListTile(
            value: SharedPreferencesHelper.instance.showAccuracyAsFraction,
            title: Text('Show accuracy as fraction of days'),
            onChanged: (value) {
              setState(() {
                SharedPreferencesHelper.instance.showAccuracyAsFraction = value;
              });
            },
          ),
          SwitchListTile(
            value:
                SharedPreferencesHelper.instance.showCompletedCategoriesInGraph,
            title: Text(
                'Show completed categories in graph and current statistics'),
            onChanged: (value) {
              setState(() {
                SharedPreferencesHelper
                    .instance.showCompletedCategoriesInGraph = value;
              });
            },
          ),
          SwitchListTile(
            value: SharedPreferencesHelper
                .instance.showCompletedCategoriesInLifetimeSummary,
            title: Text('Show completed categories in lifetime summary'),
            onChanged: (value) {
              setState(() {
                SharedPreferencesHelper
                    .instance.showCompletedCategoriesInLifetimeSummary = value;
              });
            },
          )
        ],
      ),
    );
  }
}
