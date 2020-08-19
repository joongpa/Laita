import 'package:flutter/material.dart';

class CustomMenuItem<T> extends PopupMenuEntry {
  final T value;
  final Text text;
  final onPressed;

  CustomMenuItem({this.value, this.text, this.onPressed}) : super();

  @override
  _CustomMenuItemState createState() => _CustomMenuItemState();

  @override
  double get height => 100;

  @override
  bool represents(value) => this.value == value;
}

class _CustomMenuItemState extends State<CustomMenuItem> {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: widget.text,
      onPressed: () {
        Navigator.pop(context);
        widget.onPressed();
      },
    );
  }
}
