import 'dart:async';

import 'package:flutter/cupertino.dart';

class ErrorHandlingModel extends ChangeNotifier {
  ErrorHandlingModel._();
  static final instance = ErrorHandlingModel._();

  StreamController<bool> _hasError = StreamController();

  Stream<bool> get hasError => _hasError.stream;
  void addValue(bool value) {
    _hasError.add(value);
  }
}