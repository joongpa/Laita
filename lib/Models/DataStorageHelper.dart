//import 'package:intl/intl.dart';
//import 'package:miatracker/Models/GoalEntry.dart';
//import 'package:miatracker/Models/InputEntry.dart';
//import 'package:miatracker/Models/InputHoursUpdater.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:sqflite/sqflite.dart';
//import 'package:path/path.dart';
//
//import '../Map.dart';
//import 'Entry.dart';
//
//class DataStorageHelper {
//  DataStorageHelper._();
//  static final _dsh = DataStorageHelper._();
//
//  factory DataStorageHelper() {
//    return _dsh;
//  }
//
//  final id = "id";
//  final inputEntries = "inputEntries";
//  final date = "date";
//  final time = "time";
//  final description = "description";
//  final inputType = "inputType";
//  final duration = "duration";
//
//  final goalEntries = 'goalEntries';
//  final amount = "duration";
//
//  Database _database;
//  Database _goalsDatabase;
//  SharedPreferences _pref;
//
//  init() async {
//    _database = await initDb();
//    _goalsDatabase = await initGoalsDb();
//    _pref = await SharedPreferences.getInstance();
//    InputHoursUpdater.ihu.addEntry(await getInputEntries());
//    InputHoursUpdater.ihu.addGoalEntry(await getGoalHistory());
//  }
//
//  Future<Database> get database async {
//    if (_database != null) return _database;
//    _database = await initDb();
//    return _database;
//  }
//
//  Future<Database> get goalsDatabase async {
//    if(_goalsDatabase != null) return _goalsDatabase;
//    _goalsDatabase = await initGoalsDb();
//    return _goalsDatabase;
//  }
//
//  Future<Database> initDb() async {
//    var databasePath = await getDatabasesPath();
//    String path = join(databasePath, 'InputEntries.db');
//
//    return await openDatabase(
//        path,
//        version: 1,
//        onCreate: (Database db, int version) async {
//          await db.execute(
//            '''
//            CREATE TABLE $inputEntries(
//              $id INTEGER PRIMARY KEY AUTOINCREMENT,
//              $date TEXT,
//              $time TEXT,
//              $description TEXT,
//              $inputType TEXT,
//              $duration REAL
//            )
//          '''
//          );
//        }
//    );
//  }
//
//  Future<Database> initGoalsDb() async {
//    var databasePath = await getDatabasesPath();
//    String path = join(databasePath, 'GoalEntries.db');
//
//    return await openDatabase(
//        path,
//        version: 1,
//        onCreate: (Database db, int version) async {
//          await db.execute(
//              '''
//            CREATE TABLE $goalEntries(
//              $id INTEGER PRIMARY KEY AUTOINCREMENT,
//              $date TEXT,
//              $time TEXT,
//              $inputType TEXT,
//              $duration REAL
//            )
//          '''
//          );
//        }
//    );
//  }
//
//  Future<List<InputEntry>> getInputEntries() async {
//    final db = await database;
//
//    var result = await db.query(inputEntries);
//    return result.map<InputEntry>((c) => InputEntry.fromMap(c)).toList() ?? [];
//  }
//
//  Future<int> insertInputEntry(InputEntry inputEntry) async {
//    final db = await database;
//
//    await db.insert(inputEntries, inputEntry.toMap()).then((data) async {
//      InputHoursUpdater.ihu.addEntry(await getInputEntries());
//      return data;
//    });
//    return 0;
//  }
//
//  Future<int> deleteEntry(Entry entry) async {
//    int id = entry.id;
//    if(entry is InputEntry) {
//      final db = await database;
//      await db.delete(inputEntries, where: '${this.id} = ?', whereArgs: [id])
//          .then((data) async {
//        InputHoursUpdater.ihu.addEntry(await getInputEntries());
//        return data;
//      });
//      return 0;
//    } else {
//      final db = await goalsDatabase;
//      await db.delete(goalEntries, where: '${this.id} = ?', whereArgs: [id]).then((data) async {
//        InputHoursUpdater.ihu.addGoalEntry(await getGoalHistory());
//        _setPrefsGoal(entry.inputType, await getLastGoalEntry(entry.inputType));
//        return data;
//      });
//      return 0;
//    }
//  }
//
//  void deleteAllInputEntries() async {
//    final db = await database;
//    db.rawDelete('DELETE FROM $inputEntries');
//  }
//
//  Future<double> getTotalHoursInput(Category inputType, DateTime startDate, [DateTime endDate]) async {
//    final start1 = DateFormat("yyyy-MM-dd").format(startDate);
//    final end1 = DateFormat("yyyy-MM-dd").format(endDate ?? daysAgo(-1,startDate));
//    final db = await database;
//    final result = await db.query(inputEntries, columns: ['SUM($duration)'], where: '$date >= ? AND $date < ? AND ${this.inputType} = ?', whereArgs: [start1, end1, inputType.name]);
//
//    return result[0]['SUM($duration)'] ?? 0;
//  }
//
//  Future<List<InputEntry>> getInputEntriesFor(DateTime startDate, DateTime endDate, {Category inputType}) async {
//    final start1 = DateFormat("yyyy-MM-dd").format(startDate);
//    final end1 = DateFormat("yyyy-MM-dd").format(endDate ?? daysAgo(-1,startDate));
//    final db = await database;
//    var result;
//    if(inputType != null)
//      result = await db.query(inputEntries, where: '$date >= ? AND $date < ? AND ${this.inputType} = ?', whereArgs: [start1, end1, inputType.name]);
//    else result = await db.query(inputEntries, where: '$date >= ? AND $date < ?', whereArgs: [start1, end1]);
//    return result.map<InputEntry>((c) => InputEntry.fromMap(c)).toList();
//  }
//
//  double getGoalOfInput(Category inputType) {
//    return _pref.get('goals' + inputType.name) ?? 0;
//  }
//
//  Future<double> getLastGoalEntry(Category inputType) async {
//    final db = await goalsDatabase;
//
//    final result = await db.query(goalEntries, where: '${this.inputType} = ?', whereArgs: [inputType.name], orderBy: '$id DESC', limit: 1);
//    if(result.length == 0) return 0.0;
//    return result.map<double>((i) => i['$amount']).first ?? 0.0;
//  }
//
//  Future<int> setGoalOfInput(Category inputType, double hours) async{
//    _setPrefsGoal(inputType, hours);
//
//    final db = await goalsDatabase;
//
//    final goalEntry = GoalEntry.now(inputType: inputType, amount: hours);
//    db.insert(goalEntries, goalEntry.toMap()).then((data) async {
//      InputHoursUpdater.ihu.addGoalEntry(await getGoalHistory());
//      return data;
//    });
//    return 0;
//  }
//
//  void _setPrefsGoal(Category inputType, double hours) {
//    _pref.setDouble('goals' + inputType.name, hours);
//  }
//
//  Future<List<GoalEntry>> getGoalHistory() async {
//    final db = await goalsDatabase;
//    final result = await db.query(goalEntries);
//    return result.map<GoalEntry>((i) => GoalEntry.fromMap(i)).toList() ?? [];
//  }
//
//  Category getCategory(String name) {
//    for(final category in allCategories) {
//      if(category.name == name) return category;
//    }
//    return null;
//  }
//
//  void removeCategory(String name) {
//    final tempList = categoryNames;
//    tempList.remove(name);
//    _pref.setStringList('categories', tempList);
//    InputHoursUpdater.ihu.resumeUpdate();
//  }
//
//  List<Category> get categories {
//    return categoryNames.map<Category>((c) => Category(name: c)).toList();
//  }
//
//  List<String> get categoryNames {
//    return _pref.getStringList("categories") ?? [];
//  }
//
//  List<Category> get allCategories {
//    return allCategoryNames.map<Category>((c) => Category(name: c)).toList();
//  }
//
//  List<String> get allCategoryNames {
//    return _pref.getStringList('allCategories') ?? [];
//  }
//
//
//  bool addCategory(String category) {
//    if(!categoryNames.contains(category)) {
//      final tempList = categoryNames;
//      tempList.add(category);
//      _pref.setStringList("categories", tempList);
//
//      if(!allCategoryNames.contains(category)) {
//        final allTempList = allCategoryNames;
//        allTempList.add(category);
//        _pref.setStringList("allCategories", allTempList);
//      }
//      InputHoursUpdater.ihu.resumeUpdate();
//      return true;
//    }
//    return false;
//  }
//
//
//  void testPopulate() async {
//    //final rand = Random();
//    Category inputType = categories[0];
//    for(int i = 0; i < 200; i++) {
//      for(int j = 0; j < 10; j++) {
////        switch(rand.nextInt(3)){
////          case 0:
////            inputType = InputType.Reading;
////            break;
////          case 1:
////            inputType = InputType.Listening;
////            break;
////          case 2:
////            inputType = InputType.Anki;
////            break;
////        }
//        final inputEntry = InputEntry(dateTime: daysAgo(i), amount: 1.0, inputType: inputType, description: "yeetem");
//        insertInputEntry(inputEntry);
//        print(inputEntry);
//        await new Future.delayed(const Duration(milliseconds: 100));
//      }
//    }
//  }
//
//  void clearSharePreferences() {
//    _pref.clear();
//  }
//}
