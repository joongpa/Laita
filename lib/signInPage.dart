import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:miatracker/Map.dart';
import 'package:miatracker/Media/media_selection_model.dart';
import 'package:miatracker/Models/aggregate_data_model.dart';
import 'package:miatracker/Models/database.dart';
import 'package:miatracker/Models/tab_change_notifier.dart';
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
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.blue]
              )
            ),
            child: Center(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                elevation: 10,
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text('LAITA', style: TextStyle(
                        fontSize: 72,
                        fontFamily: 'Times New Roman'
                      ),),
                      Text('Language-Agnostic Input Tracker App', style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontFamily: ''
                      ),),
                      SizedBox(height: 50),
                      SignInButton(
                        Buttons.Google,
                      padding: EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      onPressed: () {
                        AuthService.instance.googleSignIn();
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {

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
            title: "LAITA",
          ));
    }
  }
}
