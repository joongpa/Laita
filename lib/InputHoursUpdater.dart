import 'package:miatracker/DataStorageHelper.dart';
import 'package:rxdart/rxdart.dart';

class InputHoursUpdater {

  InputHoursUpdater._();
  static final InputHoursUpdater ihu = InputHoursUpdater._();

  BehaviorSubject _update = BehaviorSubject.seeded(0.0);
  Stream get updateStream$ => _update.stream;

  BehaviorSubject _readingHours = BehaviorSubject.seeded(0.0);
  Stream get rStream$ => _readingHours.stream;
  double get rCurrent => _readingHours.value;

  BehaviorSubject _readingGoal = BehaviorSubject.seeded(0.0);
  Stream get rgStream$ => _readingGoal.stream;

  void update() {
    _update.add(0.0);
  }

  void addReading(double hours) {
    _readingHours.add(rCurrent + hours);
    //DataStorageHelper.dsh.addReading(hours);
  }

  void setReadingGoal(double hours) {
    _readingGoal.add(hours);
    //DataStorageHelper.dsh.setReadingGoals(hours);
  }

  BehaviorSubject _listeningHours = BehaviorSubject.seeded(0.0);
  Stream get lStream$ => _listeningHours.stream;
  double get lCurrent => _listeningHours.value;

  BehaviorSubject _listeningGoal = BehaviorSubject.seeded(0.0);
  Stream get lgStream$ => _listeningGoal.stream;

  void addListening(double hours) {
    _listeningHours.add(lCurrent + hours);
    //DataStorageHelper.dsh.addReading(hours);
  }

  void setListeningGoal(double hours) {
    _listeningGoal.add(hours);
    //DataStorageHelper.dsh.setListeningGoals(hours);
  }

  BehaviorSubject _ankiHours = BehaviorSubject.seeded(0.0);
  Stream get aStream$ => _ankiHours.stream;
  double get aCurrent => _ankiHours.value;

  BehaviorSubject _ankiGoal = BehaviorSubject.seeded(0.0);
  Stream get agStream$ => _ankiGoal.stream;

  void addAnki(double hours) {
    _ankiHours.add(aCurrent + hours);
    //DataStorageHelper.dsh.addReading(hours);
  }

  void setAnkiGoal(double hours) {
    _ankiGoal.add(hours);
    //DataStorageHelper.dsh.setAnkiGoals(hours);
  }
}