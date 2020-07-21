import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
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

  final id = "id";
  final inputEntries = "inputEntries";
  final date = "date";
  final time = "time";
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
              $id INTEGER PRIMARY KEY AUTOINCREMENT,
              $date TEXT,
              $time TEXT,
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

  Future<List<InputEntry>> getInputEntriesOnDay(DateTime dateTime) async {
    String compare = DateFormat('yyyy-MM-dd').format(dateTime);
    final db = await database;
    var result = await db.query(inputEntries, where: '${this.date} = ?', whereArgs: [compare]);
    return result.map<InputEntry>((c) => InputEntry.fromMap(c)).toList();
  }

  Future<double> calculateInputToday(InputType inputType) async{
    return getTotalHoursInput(inputType, DateTime.now());
  }

  Future<int> updateInputEntry(InputEntry inputEntry) async {
    final db = await database;

    int result = await db.update("$inputEntries", inputEntry.toMap(), where: '$id = ?', whereArgs: [inputEntry.id]);
    return result;
  }

  Future<int> deleteInputEntry(int id) async {
    final db = await database;
    int result = await db.delete(inputEntries, where: '${this.id} = ?', whereArgs: [id]);
    return result;
  }

  void deleteAllInputEntries() async {
    final db = await database;
    db.rawDelete('DELETE FROM $inputEntries');
  }

  Future<double> getTotalHoursInput(InputType inputType, DateTime startDate, [DateTime endDate]) async {
    final start1 = DateFormat("yyyy-MM-dd").format(startDate);
    final end1 = DateFormat("yyyy-MM-dd").format(endDate ?? startDate);
    final db = await database;
    final result = await db.query(inputEntries, columns: ['SUM($duration)'], where: '$date >= ? AND $date <= ? AND ${this.inputType} = ?', whereArgs: [start1, end1, inputType.name]);
    return result[0]['SUM($duration)'] ?? 0;
  }

  Future<List<InputEntry>> getInputEntriesFor(DateTime startDate, DateTime endDate, {InputType inputType}) async {
    final start1 = DateFormat("yyyy-MM-dd").format(startDate);
    final end1 = DateFormat("yyyy-MM-dd").format(endDate ?? startDate);
    final db = await database;
    var result;
    if(inputType != null)
      result = await db.query(inputEntries, where: '$date >= ? AND $date <= ? AND ${this.inputType} = ?', whereArgs: [start1, end1, inputType.name]);
    else result = await db.query(inputEntries, where: '$date >= ? AND $date <= ?', whereArgs: [start1, end1]);
    return result.map<InputEntry>((c) => InputEntry.fromMap(c)).toList();
  }

  double getGoalOfInput(InputType inputType) {
    return _pref.get('goals' + inputType.name) ?? 0;
  }

  void setGoalOfInput(InputType inputType, double hours) {
    _pref.setDouble('goals' + inputType.name, hours);
  }


  void testPopulate() async {
    final rand = Random();
    InputType inputType;
    for(int i = 0; i < 200; i++) {
      for(int j = 0; j < 10; j++) {
        switch(rand.nextInt(3)){
          case 0:
            inputType = InputType.Reading;
            break;
          case 1:
            inputType = InputType.Listening;
            break;
          case 2:
            inputType = InputType.Anki;
            break;
        }
        final inputEntry = InputEntry(dateTime: daysAgo(i), duration: 1.0, inputType: inputType, description: "yeetem");
        insertInputEntry(inputEntry);
        print(inputEntry);
        await new Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }
}