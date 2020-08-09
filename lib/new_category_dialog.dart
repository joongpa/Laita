import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Models/category.dart';
import 'Models/user.dart';

class NewCategoryDialog extends StatefulWidget {
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
              ]
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Select type of input',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Quantity"),
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
              Text("Time"),
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
                addDate: DateTime.now());
            Navigator.of(context).pop(category);
            _newCategoryDialogController.clear();
          },
        )
      ],
    );
  }
}
