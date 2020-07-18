import 'package:miatracker/InputEntry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'Map.dart';

class DataStorageHelper {
  DataStorageHelper._();
  static final _dsh = DataStorageHelper._();

  factory DataStorageHelper() {
    return _dsh;
  }

  final inputEntries = "inputEntries";
  final dateTime = "dateTime";
  final description = "description";
  final inputType = "inputType";
  final duration = "duration";

  Database _database;
  SharedPreferences _pref;

  init() async {
    _database = await initDb();
    _pref = await SharedPreferences.getInstance();
  }

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDb();
    return _database;
  }

  Future<Database> initDb() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, 'InputEntries.db');

    return await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
            '''
            CREATE TABLE $inputEntries(
              $dateTime TEXT,
              $description TEXT,
              $inputType TEXT,
              $duration REAL
            )
          '''
          );
        }
    );
  }

  Future<List<InputEntry>> getInputEntries() async {
    final db = await database;

    var result = await db.query('$inputEntries');
    return result.map<InputEntry>((c) => InputEntry.fromMap(c)).toList();
  }

  Future<int> insertInputEntry(InputEntry inputEntry) async {
    final db = await database;

    int result = await db.insert("$inputEntries", inputEntry.toMap());
    return result;
  }

  Future<List<InputEntry>> findInputEntriesOnDay(DateTime dateTime) async {
    String compare = '^${dateTime.year}-${dateTime.month}-${dateTime.day}';
    final db = await database;
    var result = await db.query('SELECT FROM $inputEntries WHERE $dateTime = "$compare"');
    return result.map<InputEntry>((c) => InputEntry.fromMap(c)).toList();
  }

  Future<int> updateInputEntry(InputEntry inputEntry) async {
    final db = await database;

    int result = await db.update("$inputEntries", inputEntry.toMap(), where: '$dateTime = ?', whereArgs: [inputEntry.dateTime.toString()]);
    return result;
  }

  Future<int> deleteInputEntry(String dateTime) async {
    final db = await database;
    int result = await db.rawDelete('DELETE FROM $inputEntries WHERE "${this.dateTime}" = "$dateTime"');
    return result;
  }

  void deleteAllInputEntries() async {
    final db = await database;
    db.rawDelete('DELETE FROM $inputEntries');
    //db.execute("DROP TABLE IF EXISTS $inputEntries");
  }










  double getHoursOfInput(InputType inputType) {
    return _pref.get('hours' + inputType.name) ?? 0;
  }

  double getGoalOfInput(InputType inputType) {
    return _pref.get('goals' + inputType.name) ?? 0;
  }

  void addInput(InputType inputType, double hours) {
    double totalHours = (_pref.get('hours' + inputType.name) ?? 0.0) +
        hours;
    _pref.setDouble('hours' + inputType.name, totalHours);
  }

  void setGoalOfInput(InputType inputType, double hours) {
    _pref.setDouble('goals' + inputType.name, hours);
  }

  void resetAllHours() {
    _pref.setDouble("hoursReading", 0);
    _pref.setDouble("hoursListening", 0);
    _pref.setDouble("hoursAnki", 0);
  }
}