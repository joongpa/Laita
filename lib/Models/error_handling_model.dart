import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

class ErrorHandlingModel {
  ErrorHandlingModel._();
  static final instance = ErrorHandlingModel._();

  BehaviorSubject<bool> _hasError = BehaviorSubject.seeded(false);

  Stream<bool> get hasError => _hasError.stream;
  void addValue(bool value) {
    _hasError.add(value);
  }
}