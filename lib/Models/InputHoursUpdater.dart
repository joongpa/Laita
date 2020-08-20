import 'package:flutter/cupertino.dart';
import 'package:miatracker/Models/TimeFrameModel.dart';
import 'package:miatracker/Models/aggregate_data_model.dart';
import 'package:miatracker/Models/user.dart';
import 'package:rxdart/rxdart.dart';

import 'category.dart';
import '../Map.dart';
import 'Entry.dart';
import 'GoalEntry.dart';
import 'InputEntry.dart';

class InputHoursUpdater {
  InputHoursUpdater._();

  static final InputHoursUpdater instance = InputHoursUpdater._();

  BehaviorSubject _update = BehaviorSubject.seeded(0.0);
  Stream get updateStream$ => _update.stream;

  void resumeUpdate() {
    TimeFrameModel().refresh();
    _update.add(1.0);
  }
}
