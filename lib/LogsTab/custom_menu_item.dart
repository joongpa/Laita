import 'package:flutter/material.dart';
import 'package:miatracker/Models/user.dart';

class CustomMenuItem extends PopupMenuEntry<Category> {
  final Category category;
  final Text text;
  final onPressed;

  CustomMenuItem({this.category, this.text, this.onPressed}) : super();

  @override
  _CustomMenuItemState createState() => _CustomMenuItemState();

  @override
  double get height => 100;

  @override
  bool represents(value) => category == value;
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
