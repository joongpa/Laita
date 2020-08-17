import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'Map.dart';
import 'Models/category.dart';
import 'Models/user.dart';

class NewCategoryDialog extends StatefulWidget {
  final int index;

  NewCategoryDialog(this.index);

  @override
  _NewCategoryDialogState createState() => _NewCategoryDialogState();
}

class _NewCategoryDialogState extends State<NewCategoryDialog> {
  TextEditingController _newCategoryDialogController = TextEditingController();
  bool isTimeBased = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
              controller: _newCategoryDialogController,
              decoration: InputDecoration(hintText: "Name of category"),
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
              ]),
          SizedBox(
            height: 20,
          ),
          Text(
            'Select type of category',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: 'Quantity',
                      style: TextStyle(color: Colors.black, fontSize: 20)),
                  TextSpan(
                      text: '\n# (1, 2, 3...)',
                      style: TextStyle(color: Colors.grey, fontSize: 15))
                ]),
              ),
              Switch(
                value: isTimeBased,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey,
                activeColor: Colors.white,
                activeTrackColor: Colors.grey,
                onChanged: (value) {
                  setState(() {
                    isTimeBased = value;
                  });
                },
              ),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: 'Time',
                      style: TextStyle(color: Colors.black, fontSize: 20)),
                  TextSpan(
                      text: '\nHH:mm',
                      style: TextStyle(color: Colors.grey, fontSize: 15))
                ]),
              ),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: const Text('OK'),
          onPressed: () {
            Category category = Category(
                name: _newCategoryDialogController.text,
                isTimeBased: isTimeBased,
                addDate: DateTime.now(),
                color: Global.defaultColors[widget.index],
                lifetimeAmount: 0,
                goalAmount: 0);
            Navigator.of(context).pop(category);
            _newCategoryDialogController.clear();
          },
        )
      ],
    );
  }
}
