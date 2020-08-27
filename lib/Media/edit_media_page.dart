import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miatracker/Map.dart';
import 'package:miatracker/Models/database.dart';
import 'package:miatracker/Models/media.dart';
import 'package:miatracker/Models/user.dart';

class EditMediaPage extends StatefulWidget {
  final AppUser user;
  final Media media;

  EditMediaPage({this.user, this.media});

  @override
  _EditMediaPageState createState() => _EditMediaPageState();
}

class _EditMediaPageState extends State<EditMediaPage> {
  GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var timeController = TextEditingController(text: '0:00');
  var episodeCountController = TextEditingController();

  bool buttonDisabled = true;

  double timePerEpisode;
  int episodeCount;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.media.name;
    timeController.text = convertToDisplay(widget.media.timePerUnit, true);
    episodeCountController.text = (widget.media.episodeCount == null)
        ? ''
        : widget.media.episodeCount.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (nameController.text != '')
      buttonDisabled = false;
    else
      buttonDisabled = true;

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Edit Media'),
        leading: FlatButton(
          child: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _globalKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(50),
                ],
                onChanged: (value) {
                  setState(() {});
                },
              ),
              TextFormField(
                controller: timeController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                    labelText: 'Time per episode/chapter (HH:mm)'),
                validator: (value) {
                  widget.media.timePerUnit = parseTime(value);
                  if (widget.media.timePerUnit == null)
                    return 'Invalid';
                  else
                    return null;
                },
              ),
              TextFormField(
                controller: episodeCountController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                    labelText: 'Episode/Chapter count (optional)'),
                validator: (value) {
                  widget.media.episodeCount = int.tryParse(value);
                  if (widget.media.episodeCount == null && value != '')
                    return 'Invalid';
                  else
                    return null;
                },
              ),
              SizedBox(height: 20),
              RaisedButton(
                onPressed: (buttonDisabled)
                    ? null
                    : () {
                        if (_globalKey.currentState.validate()) {
                          widget.media.name = nameController.text;
                          DatabaseService.instance
                              .updateMedia(widget.user, widget.media);

                          Navigator.of(context).pop();
                        }
                      },
                color: Colors.blue,
                child: Text(
                  'Done',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget choiceButton(String text) => Padding(
        padding: EdgeInsets.all(10.0),
        child: Text(text),
      );

  @override
  void dispose() {
    timeController.dispose();
    nameController.dispose();
    episodeCountController.dispose();
    super.dispose();
  }
}
