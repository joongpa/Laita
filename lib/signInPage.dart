import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/Map.dart';
import 'package:miatracker/Media/media_selection_model.dart';
import 'package:miatracker/Models/aggregate_data_model.dart';
import 'package:miatracker/Models/database.dart';
import 'package:miatracker/Models/tab_change_notifier.dart';
import 'Models/GoalEntry.dart';
import 'Models/InputEntry.dart';
import 'Models/category.dart';
import 'Models/auth.dart';
import 'package:miatracker/main.dart';
import 'package:provider/provider.dart';

import 'Models/user.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    var loading = Provider.of<bool>(context) ?? false;
    bool loggedIn = user != null;

    if (loading) {
      return SafeArea(
          child: Scaffold(
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(
              height: 20,
            ),
            Text("Logging you in..."),
          ],
        )),
      ));
    }

    if (!loggedIn) {
      return SafeArea(
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                    child: Text("Sign In With Google"),
                    onPressed: () {
                      AuthService.instance.googleSignIn();
                    }),
                RaisedButton(
                    child: Text("Sign In Anonymously"),
                    onPressed: () {
                      AuthService.instance.signInAnonymously();
                    })
              ],
            ),
          ),
        ),
      );
    } else
      return MultiProvider(
          providers: [
            StreamProvider<AppUser>.value(
              value: DatabaseService.instance.appUserStream(user),
            ),
            StreamProvider<Map<DateTime, DailyInputEntry>>.value(
              initialData: {},
              value: DatabaseService.instance.dailyInputEntriesStream(user.uid,
                  startDate: daysAgo(0), endDate: daysAgo(-1)),
            ),
            ChangeNotifierProvider<TabChangeNotifier>.value(
              value: TabChangeNotifier.instance,
            ),
            ChangeNotifierProvider<MediaSelectionModel>.value(
                value: MediaSelectionModel.instance)
          ],
          child: MyHomePage(
            title: "Immersion Tracker",
          ));
  }
}
