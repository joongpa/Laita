import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/GoalsPageWidget.dart';
import 'Models/category.dart';
import 'file:///C:/Users/Jeff%20Park/AndroidStudioProjects/mia_tracker/lib/Models/auth.dart';
import 'package:provider/provider.dart';

class DrawerMenu extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    var categories = Provider.of<List<Category>>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _createHeader(),
          _createDrawerItem(
            icon: Icons.beenhere,
            text: 'Goals',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) {
                    return MultiProvider(
                      providers: [
                        StreamProvider<FirebaseUser>.value(
                            value: FirebaseAuth.instance.onAuthStateChanged),
                      ],
                      child: GoalsPageWidget(),
                    );
                  },
                ),
              );
            },
          ),
          Divider(),
          _createDrawerItem(
            icon: Icons.contacts,
            text: "Log out",
            onTap: () {
              AuthService.instance.signOut();
            },
          )
        ],
      ),
    );
  }

  Widget _createHeader() {
    return DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(),
        child: Stack(children: <Widget>[
          Positioned(
              bottom: 12.0,
              left: 16.0,
              child: Text("Immersion Tracker",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500))),
        ]));
  }

  Widget _createDrawerItem(
      {IconData icon, String text, GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(text),
          )
        ],
      ),
      onTap: onTap,
    );
  }
}
