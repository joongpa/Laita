import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/AddHours.dart';
import 'package:miatracker/DataStorageHelper.dart';
import 'package:miatracker/DrawerMenu.dart';
import 'package:miatracker/GlobalProgressWidget.dart';
import 'package:flutter/services.dart';
import 'package:miatracker/InputHoursUpdater.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataStorageHelper().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      title: 'MIA Tracker',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Immersion Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final bucket = PageStorageBucket();
  int selectedIndex = 0;

  final pageNames = [
    "Daily Goals",
    "Log",
  ];

  onItemTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(pageNames[selectedIndex]),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: IndexedStack(
          index: selectedIndex,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                StreamBuilder<Object>(
                    stream: InputHoursUpdater.ihu.rStream$,
                    builder: (context, snapshot) {
                      return GlobalProgressWidget(
                          "Reading", snapshot.data, InputHoursUpdater.ihu.rgStream$);
                    }),
                GlobalProgressWidget("Listening", 0, InputHoursUpdater.ihu.lgStream$),
                GlobalProgressWidget("Anki", 0, InputHoursUpdater.ihu.agStream$),
              ],
            ),
            Container(),
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
              title: Text('Home'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              title: Text('Log'),
            )
          ],
          currentIndex: selectedIndex,
          onTap: onItemTap,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddHours()),
          );
        },
      ),
    );
  }
}
