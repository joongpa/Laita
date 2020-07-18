import 'package:flutter/foundation.dart';

enum InputType {
  Reading, Listening, Anki
}

extension InputTypeExtension on InputType {
  String get name => describeEnum(this);
}