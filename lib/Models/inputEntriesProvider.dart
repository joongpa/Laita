import 'package:flutter/cupertino.dart';
import 'package:miatracker/Models/Entry.dart';
import 'package:miatracker/Models/database.dart';
import 'package:miatracker/Models/user.dart';

import 'InputEntry.dart';

class InputEntriesProvider extends ChangeNotifier {
  InputEntriesProvider._();
  static InputEntriesProvider instance = InputEntriesProvider._();

  List<Entry> _entries;
  List<Entry> get entries => _entries;

  getEntriesOnDay(AppUser user, DateTime dateTime) async {
    _entries = null;
    notifyListeners();
    _entries = await DatabaseService.instance.getEntriesOnDay(user, dateTime);
    notifyListeners();
  }

  void remove(AppUser user, InputEntry inputEntry) {
    _entries.remove(inputEntry);
    notifyListeners();
    DatabaseService.instance.deleteInputEntry(user, inputEntry);
  }
}