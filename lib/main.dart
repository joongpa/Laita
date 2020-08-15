import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/DailyGoalsTab/AddHours.dart';
import 'package:miatracker/DailyGoalsTab/ProgressListWidget.dart';
import 'package:miatracker/DrawerMenu.dart';
import 'package:flutter/services.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';
import 'package:miatracker/Models/Lifecycle.dart';
import 'Models/category.dart';
import 'Models/auth.dart';
import 'package:miatracker/signInPage.dart';
import 'package:provider/provider.dart';
import 'Models/user.dart';

import 'LogsTab/MultiInputLog.dart';
import 'StatsTab/StatisticsSummaryWidget.dart';
import 'anti_scroll_glow.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MultiProvider(
      providers: [
        StreamProvider<bool>.value(
          value: AuthService.instance.loading
        ),
        StreamProvider<FirebaseUser>.value(
          value: FirebaseAuth.instance.onAuthStateChanged
        ),
      ],
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: MaterialApp(
          builder: (context, child) {
            return ScrollConfiguration(
              behavior: MyBehavior(),
              child: child,
            );
          },
          title: 'MIA Tracker',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: SignInPage(),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);


  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final bucket = PageStorageBucket();
  int selectedIndex = 0;
  bool visible = true;

  final pageNames = ["Daily Goals", "Statistics", "Log"];

  onItemTap(int index) {
    setState(() {
      selectedIndex = index;
      if (index != 0)
        visible = false;
      else
        visible = true;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addObserver(LifecycleEventHandler(resumeCallBack: () async {
      InputHoursUpdater.ihu.resumeUpdate();
    }));
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AppUser>(context);
    user ??= AppUser();

    return Scaffold(
      appBar: AppBar(
        title: Text(pageNames[selectedIndex]),
      ),
      body: Center(
        child: IndexedStack(
          index: selectedIndex,
          children: <Widget>[
            ProgressListWidget(),
            StatisticsSummaryWidget(),
            MultiInputLog(),
          ],
        ),
      ),
      endDrawer: DrawerMenu(),
      bottomNavigationBar: PageStorage(
        bucket: bucket,
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('Daily Goals'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              title: Text('Stats'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              title: Text('Log'),
            ),
          ],
          currentIndex: selectedIndex,
          onTap: onItemTap,
        ),
      ),
      floatingActionButton: Visibility(
        visible: visible,
        child: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddHours(user, user.categories)),
            );
          },
        ),
      ),
    );
  }
}
