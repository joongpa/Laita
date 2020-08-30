import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

class ErrorHandlingModel {
  ErrorHandlingModel._();
  static final instance = ErrorHandlingModel._();

  BehaviorSubject<String> _hasError = BehaviorSubject.seeded(null);

  Stream<String> get hasError => _hasError.stream;
  void addValue(String value) {
    _hasError.add(value);
  }
}