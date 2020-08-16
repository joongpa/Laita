import 'package:flutter/cupertino.dart';
import 'package:miatracker/Models/Entry.dart';
import 'package:miatracker/Models/database.dart';
import 'package:miatracker/Models/user.dart';

import 'InputEntry.dart';

class InputEntriesProvider extends ChangeNotifier {
  InputEntriesProvider._();
  static InputEntriesProvider instance = InputEntriesProvider._();

  bool isLoading = true;
  Map<DateTime,List<Entry>> _entries = Map<DateTime,List<Entry>>();
  Map<DateTime,List<Entry>> get entries => _entries;

  getEntriesOnDay(AppUser user, DateTime dateTime) async {
    if(_entries[dateTime] == null) {
      isLoading = true;
      notifyListeners();
      _entries[dateTime] = await DatabaseService.instance.getEntriesOnDay(user, dateTime);
      isLoading = false;
      notifyListeners();
    } else _entries[dateTime] = await DatabaseService.instance.getEntriesOnDay(user, dateTime);
  }

  reload(AppUser user, DateTime dateTime) async {
    isLoading = true;
    notifyListeners();
    _entries.clear();
    DatabaseService.instance.entries.clear();
    await getEntriesOnDay(user, dateTime);
    isLoading = false;
    notifyListeners();
  }

  void remove(AppUser user, InputEntry inputEntry) {
    _entries.remove(inputEntry);
    DatabaseService.instance.deleteInputEntry(user, inputEntry);
  }

  void clear() {
    _entries.clear();
    DatabaseService.instance.clearCache();
  }

}