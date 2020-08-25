import 'dart:async';
import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/DailyGoalsTab/AddHours.dart';
import 'package:miatracker/DailyGoalsTab/ProgressListWidget.dart';
import 'package:miatracker/DrawerMenu.dart';
import 'package:flutter/services.dart';
import 'package:miatracker/Media/media_display_page.dart';
import 'package:miatracker/Media/new_media_page.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';
import 'package:miatracker/Models/Lifecycle.dart';
import 'package:miatracker/Models/date_time_property.dart';
import 'package:miatracker/Models/shared_preferences.dart';
import 'package:miatracker/Models/tab_change_notifier.dart';
import 'package:miatracker/StatsTab/stats_settings_page.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'Map.dart';
import 'Models/category.dart';
import 'Models/auth.dart';
import 'package:miatracker/signInPage.dart';
import 'package:provider/provider.dart';
import 'Models/user.dart';

import 'LogsTab/MultiInputLog.dart';
import 'StatsTab/StatisticsSummaryWidget.dart';
import 'anti_scroll_glow.dart';

void main() async {
  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferencesHelper.instance.init();
  DateTimeProperty.changeInDay().listen((event) {
    if(event) InputHoursUpdater.instance.resumeUpdate();
  });

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
        StreamProvider<bool>.value(value: AuthService.instance.loading),
        StreamProvider<FirebaseUser>.value(
            value: FirebaseAuth.instance.onAuthStateChanged),
        ChangeNotifierProvider<SharedPreferencesHelper>.value(
            value: SharedPreferencesHelper.instance),
      ],
      child: StreamBuilder(
        stream: InputHoursUpdater.instance.updateStream$,
        builder: (context, snapshot) {
          return MaterialApp(
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
          );
        }
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

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{
  TabController _tabController;
  final bucket = PageStorageBucket();
  int selectedIndex = 0;

  final pageNames = ["Daily Goals", "Media", "Statistics", "Log"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      TabChangeNotifier.instance.index = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  onItemTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AppUser>(context);
    user ??= AppUser();

    return Scaffold(
      appBar: AppBar(
        title: (selectedIndex == 1) ? TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'In Progress',),
            Tab(text: 'Complete'),
            Tab(text: 'Dropped'),
          ],
        ) : Text(pageNames[selectedIndex]),
        automaticallyImplyLeading: false,
        leading: (selectedIndex == 2) ? FlatButton(
          child: Icon(Icons.tune, color: Colors.white),
          onPressed: () =>
              Navigator.of(context).push(createSlideRoute(StatsSettingsPage())),
        ) : null,
      ),
      body: Center(
        child: IndexedStack(
          index: selectedIndex,
          children: <Widget>[
            ProgressListWidget(),
            MediaDisplayPage(),
            StatisticsSummaryWidget(),
            MultiInputLog(),
          ],
        ),
      ),
      endDrawer: DrawerMenu(),
      bottomNavigationBar: PageStorage(
        bucket: bucket,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('Daily Goals'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.movie),
              title: Text('Media'),
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
    );
  }
}
