import 'package:miatracker/DataStorageHelper.dart';
import 'package:rxdart/rxdart.dart';

class InputHoursUpdater {

  InputHoursUpdater._();
  static final InputHoursUpdater ihu = InputHoursUpdater._();

  BehaviorSubject _update = BehaviorSubject.seeded(0.0);
  Stream get updateStream$ => _update.stream;

  void update() {
    _update.add(0.0);
  }

  void resumeUpdate() {
    _update.add(1.0);
  }
}