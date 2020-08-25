import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miatracker/Map.dart';
import 'package:miatracker/Models/InputEntry.dart';
import 'package:miatracker/Models/database.dart';
import 'package:miatracker/Models/media.dart';
import 'package:miatracker/Models/tab_change_notifier.dart';
import 'package:miatracker/Models/user.dart';
import 'package:provider/provider.dart';

import 'media_selection_model.dart';

class NewMediaPage extends StatefulWidget {
  final Category initialCategory;
  final AppUser user;

  NewMediaPage({this.user, this.initialCategory});

  @override
  _NewMediaPageState createState() => _NewMediaPageState();
}

class _NewMediaPageState extends State<NewMediaPage> {
  GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var timeController = TextEditingController(text: '0:00');
  var episodeCountController = TextEditingController();
  var initialEpisodesWatchedController = TextEditingController();

  bool buttonDisabled = true;
  Category _selectedCategory;
  List<bool> _selections;

  double timePerEpisode;
  int episodeCount;
  int initialEpisodeWatchCount;

  List<Category> categories;

  @override
  void initState() {
    super.initState();
    categories = widget.user.categories.where((element) => element.isTimeBased).toList();
    _selectedCategory = widget.initialCategory;
    _selections = List.generate(8, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    try {
      _selections[categories.indexOf(_selectedCategory)] = true;
    } catch (e) {}

    if (nameController.text != '' && _selectedCategory != null)
      buttonDisabled = false;
    else
      buttonDisabled = true;

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('New Media'),
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
              if (categories.length != 0)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ToggleButtons(
                    children: List.generate(categories.length,
                        (index) => choiceButton(categories[index].name)),
                    borderRadius: BorderRadius.circular(10),
                    selectedColor: Colors.white,
                    fillColor: Colors.red,
                    isSelected: _selections.sublist(0, categories.length),
                    onPressed: (int index) {
                      setState(() {
                        for (int buttonIndex = 0;
                            buttonIndex < _selections.length;
                            buttonIndex++) {
                          if (buttonIndex == index) {
                            _selections[buttonIndex] = true;
                            _selectedCategory = categories[index];
                          } else {
                            _selections[buttonIndex] = false;
                          }
                        }
                      });
                    },
                  ),
                ),
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
                  timePerEpisode = parseTime(value);
                  if (timePerEpisode == null)
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
                  episodeCount = int.tryParse(value);
                  if (episodeCount == null && value != '')
                    return 'Invalid';
                  else
                    return null;
                },
              ),
              TextFormField(
                controller: initialEpisodesWatchedController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                    labelText: 'Episodes/Chapters already seen (optional)'),
                validator: (value) {
                  initialEpisodeWatchCount = int.tryParse(value);
                  if (initialEpisodeWatchCount == null && value != '')
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
                          var media = Media(
                            name: nameController.text,
                            timePerUnit: timePerEpisode,
                            episodeCount: episodeCount,
                            episodeWatchCount: 0,
                            startDate: DateTime.now(),
                            lastUpDate: DateTime.now(),
                            categoryName: _selectedCategory.name,
                          );
                          DatabaseService.instance.addMedia(widget.user, media);
                          MediaSelectionModel.instance.setSelectedSortType(SortType.lastUpdated, 'In Progress');
                          Navigator.of(context).pop();

                          if ((initialEpisodeWatchCount ?? 0) > 0 &&
                              timePerEpisode != 0) {
                            DatabaseService.instance.addInputEntry(
                                widget.user,
                                InputEntry(
                                    mediaID: media.id,
                                    episodesWatched: initialEpisodeWatchCount,
                                    dateTime: DateTime.now(),
                                    amount: initialEpisodeWatchCount *
                                        timePerEpisode,
                                    inputType: _selectedCategory.name,
                                    description: generateDescription(media, episodesWatched: initialEpisodeWatchCount, currentEpisode: initialEpisodeWatchCount)));
                          }
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
    initialEpisodesWatchedController.dispose();
    super.dispose();
  }
}
