import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/Models/database.dart';
import 'Models/GoalEntry.dart';
import 'Models/InputEntry.dart';
import 'Models/category.dart';
import 'Models/auth.dart';
import 'package:miatracker/main.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    var loading = Provider.of<bool>(context) ?? false;
    bool loggedIn = user != null;

    if(loading) {
      return SafeArea(
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 20,),
                Text("Logging you in..."),
              ],
            )
          ),
        )
      );
    }

    if(!loggedIn) {
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
                    }
                ),
                RaisedButton(
                    child: Text("Sign In Anonymously"),
                    onPressed: () {
                      AuthService.instance.signInAnonymously();
                    }
                )
              ],
            ),
          ),
        ),
      );
    } else return MultiProvider(
        providers: [
          StreamProvider<List<InputEntry>>.value(
              value: DatabaseService.instance.inputEntriesStream(user)
          ),
          StreamProvider<List<GoalEntry>>.value(
              value: DatabaseService.instance.goalEntriesStream(user)
          ),
          StreamProvider<List<Category>>.value(
              value: DatabaseService.instance.categoriesStream(user)
          )
        ],
        child: MyHomePage(title: "Immersion Tracker",));
  }
}
