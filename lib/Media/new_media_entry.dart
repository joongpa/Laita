import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miatracker/Models/InputEntry.dart';
import 'package:miatracker/Models/category.dart';
import 'package:miatracker/Models/database.dart';
import 'package:miatracker/Models/media.dart';
import 'dart:math' as math;
import '../Map.dart' as constants;
import '../DailyGoalsTab/DatePicker.dart';
import '../Models/user.dart';

class NewMediaEntry extends StatefulWidget {
  final AppUser user;
  final Media media;

  NewMediaEntry(this.user, {this.media});

  @override
  _NewMediaEntryState createState() => _NewMediaEntryState();
}

class _NewMediaEntryState extends State<NewMediaEntry> {
  GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  NumberFormat f = NumberFormat("#");
  DateTime dateTime;
  double hours = 0.0;
  double minutes = 0.0;
  bool buttonDisabled = true;

  var endController = TextEditingController();

  var newWatchCount = 0;

  @override
  void initState() {
    super.initState();
    newWatchCount = widget.media.episodeWatchCount;
    endController.text = widget.media.episodeWatchCount.toString();
    dateTime = DateTime.now();
  }

  @override
  void dispose() {
    endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text("New Immersion Entry"),
        leading: FlatButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(Icons.close, color: Colors.white,),),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 10, 20, 10),
          child: Column(
            children: <Widget>[
              Text(
                '${widget.media.name}',
                style: TextStyle(fontSize: 21),
              ),
              Form(
                key: _globalKey,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'From Ep/Ch ',
                              style: TextStyle(color: Colors.grey),
                              children: [
                                TextSpan(
                                  text: '${widget.media.episodeWatchCount}',
                                  style: TextStyle(color: Colors.black, fontSize: 17)
                                )
                              ]
                            ),
                          ),
                          TextFormField(
                            controller: endController,
                            keyboardType: TextInputType.datetime,
                            decoration: InputDecoration(labelText: 'To Ep/Ch #'),
                            onFieldSubmitted: (value) {
                              newWatchCount = int.tryParse(value) ?? newWatchCount;
                              newWatchCount = math.max<int>(newWatchCount, widget.media.episodeWatchCount);
                              endController.text = newWatchCount.toString();
                              setState(() {
                                recalculateTime();
                              });
                            },
                            validator: (value) {
                              newWatchCount = int.tryParse(value);
                              if (newWatchCount == null)
                                return 'Invalid';
                              else
                                return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          CheckboxListTile(
                            title: Text('Complete', textAlign: TextAlign.center,),
                            value: widget.media.isCompleted,
                            onChanged: (widget.media.episodeCount != null) ? null : (value) {
                              setState(() {
                                widget.media.isCompleted = value;
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MaterialButton(
                                onPressed: () {
                                  if(newWatchCount > widget.media.episodeWatchCount) {
                                    setState(() {
                                      newWatchCount--;
                                      recalculateTime();
                                    });
                                    endController.text = newWatchCount.toString();
                                  }
                                },
                                shape: CircleBorder(),
                                color: Colors.blue,
                                child: Text(
                                  '-',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              MaterialButton(
                                onPressed: () {
                                  if (widget.media.episodeCount == null || newWatchCount < widget.media.episodeCount) {
                                    setState(() {
                                      newWatchCount++;
                                      recalculateTime();
                                    });
                                    endController.text = newWatchCount.toString();
                                  }
                                },
                                shape: CircleBorder(),
                                color: Colors.blue,
                                child: Text(
                                  '+',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              DatePicker(
                selectedDate: dateTime,
                onChanged: (dt) {
                  setState(() {
                    dateTime = dt;
                    if (constants.sameDay(dt, DateTime.now())) {
                      final duration = Duration(
                          hours: DateTime.now().hour,
                          minutes: DateTime.now().minute);
                      dateTime.add(duration);
                    }
                  });
                },
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: 20),
                        children: <TextSpan>[
                          TextSpan(
                              text: f.format(math.min(12, hours)),
                              style: TextStyle(fontSize: 25)),
                          TextSpan(text: " hrs")
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Slider(
                      value: math.min(12, hours),
                      min: 0,
                      max: 12,
                      onChanged: (newValue) {
                        setState(() {
                          hours = newValue;
                          if (newValue != 0)
                            buttonDisabled = false;
                          else if (minutes == 0 && hours == 0)
                            buttonDisabled = true;
                        });
                      },
                      divisions: 12,
                      onChangeEnd: (double) {},
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: 20),
                        children: <TextSpan>[
                          TextSpan(
                              text: f.format(minutes),
                              style: TextStyle(fontSize: 25)),
                          TextSpan(text: " min")
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Slider(
                      value: minutes,
                      min: 0,
                      max: 55,
                      onChanged: (newValue) {
                        setState(() {
                          minutes = newValue;
                          if (newValue != 0)
                            buttonDisabled = false;
                          else if (minutes == 0 && hours == 0)
                            buttonDisabled = true;
                        });
                      },
                      divisions: 11,
                      onChangeEnd: (double) {},
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
              _submitButton(widget.user, widget.user.categories),
            ],
          ),
        ),
      ),
    );
  }

  Widget _submitButton(AppUser user, List<Category> categories) => RaisedButton(
    child: Text(
      "Done",
      style: TextStyle(
        color: Colors.white,
      ),
    ),
    onPressed:
    buttonDisabled ? null : () => _buttonAction(user, categories),
    color: Colors.lightBlue,
  );

  _buttonAction(AppUser user, List<Category> categories) {
    if(_globalKey.currentState.validate()) {
      double sum = hours.toDouble() + (minutes.toDouble()/60);
      DatabaseService.instance.addInputEntry(user, InputEntry(
        episodesWatched: newWatchCount - widget.media.episodeWatchCount,
        description: constants.generateDescription(widget.media, episodesWatched: newWatchCount - widget.media.episodeWatchCount, currentEpisode: newWatchCount),
        inputType: widget.media.categoryName,
        amount: sum,
        dateTime: dateTime,
        mediaID: widget.media.id,
      ));
      widget.media.lastUpDate = DateTime.now();
      DatabaseService.instance.updateMedia(user, widget.media);
      Navigator.pop(context);
    }
  }

  Widget choiceButton(String text) => Padding(
    padding: EdgeInsets.all(10.0),
    child: Text(text),
  );

  void recalculateTime() {
    hours = ((newWatchCount - widget.media.episodeWatchCount) * widget.media.timePerUnit).floor().toDouble();
    minutes = (((newWatchCount - widget.media.episodeWatchCount) * widget.media.timePerUnit) % 1 * 60).roundToDouble();
    if(hours != 0 || minutes != 0)
      buttonDisabled = false;
    else if (minutes == 0 && hours == 0)
      buttonDisabled = true;
    widget.media.isCompleted = (widget.media.episodeCount == null) ? false : newWatchCount >= widget.media.episodeCount;
  }
}
