import 'package:flutter/cupertino.dart';
import 'package:miatracker/Models/Entry.dart';
import 'package:miatracker/Models/database.dart';
import 'package:miatracker/Models/user.dart';

import 'InputEntry.dart';

class InputEntriesProvider extends ChangeNotifier {
  InputEntriesProvider._();
  static InputEntriesProvider instance = InputEntriesProvider._();

  bool isLoading = true;
  Map<DateTime,List<Entry>> entries = Map<DateTime,List<Entry>>();

  getEntriesOnDay(String uid, DateTime dateTime) async {
    if(entries[dateTime] == null) {
      isLoading = true;
      notifyListeners();
      entries[dateTime] = await DatabaseService.instance.getEntriesAsFuture(uid, dateTime: dateTime);
      isLoading = false;
      notifyListeners();
    }
  }

  void remove(AppUser user, InputEntry inputEntry) {
    DatabaseService.instance.deleteInputEntry(user, inputEntry);
  }

  void clear() {
    entries.clear();
    DatabaseService.instance.clearCache();
  }

}