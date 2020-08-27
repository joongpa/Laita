import 'package:flutter/cupertino.dart';

import 'aggregate_data_model.dart';

class DailyInputEntryPacket {
  DateTime startDate;
  DateTime endDate;
  Map<DateTime, DailyInputEntry> dailyInputEntries;

  DailyInputEntryPacket(
      {@required this.startDate,
      @required this.endDate,
      @required this.dailyInputEntries});
}
