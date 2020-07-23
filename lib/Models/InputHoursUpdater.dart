import 'package:rxdart/rxdart.dart';

import 'InputEntry.dart';

class InputHoursUpdater {

  InputHoursUpdater._();
  static final InputHoursUpdater ihu = InputHoursUpdater._();

  BehaviorSubject _update = BehaviorSubject.seeded(0.0);
  Stream get updateStream$ => _update.stream;

  BehaviorSubject<List<InputEntry>> _dbChanges = BehaviorSubject.seeded([]);
  Stream get dbChangesStream$ => _dbChanges.stream;

  void update() {
    _update.add(0.0);
  }

  void addEntry(List<InputEntry> data) {
    _dbChanges.add(data);
  }

  void resumeUpdate() {
    _update.add(1.0);
  }
}