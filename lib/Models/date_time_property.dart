
import 'package:miatracker/Map.dart';

class DateTimeProperty {
  static Stream<bool> changeInDay() async* {
    while(true) {
      Duration waitTime = daysAgo(-1).difference(DateTime.now()) + Duration(seconds: 2);
      await Future.delayed(waitTime);
      yield true;
    }
  }
}
