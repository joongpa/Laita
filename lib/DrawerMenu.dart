import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/GoalsPageWidget.dart';
import 'package:miatracker/Models/database.dart';
import 'package:miatracker/Models/input_entries_provider.dart';
import 'package:miatracker/Models/user.dart';
import 'package:provider/provider.dart';
import 'Models/auth.dart';

class DrawerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);

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
                        StreamProvider<AppUser>.value(
                          value: DatabaseService.instance.appUserStream(user),
                        ),
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
              InputEntriesProvider.instance.clear();
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
