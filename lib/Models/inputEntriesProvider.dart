import 'package:flutter/cupertino.dart';
import 'package:miatracker/Models/Entry.dart';
import 'package:miatracker/Models/database.dart';
import 'package:miatracker/Models/user.dart';

import 'InputEntry.dart';

class InputEntriesProvider extends ChangeNotifier {
  InputEntriesProvider._();
  static InputEntriesProvider instance = InputEntriesProvider._();

  bool isLoading = true;
  List<Entry> _entries;
  List<Entry> get entries => _entries;

  getEntriesOnDay(AppUser user, DateTime dateTime) async {
    isLoading = true;
    notifyListeners();

    _entries = await DatabaseService.instance.getEntriesOnDay(user, dateTime);
    isLoading = false;
    notifyListeners();
  }

  void remove(AppUser user, InputEntry inputEntry) {
    _entries.remove(inputEntry);
    DatabaseService.instance.deleteInputEntry(user, inputEntry);
  }
}