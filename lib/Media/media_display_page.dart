import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/DailyGoalsTab/AddHours.dart';
import 'package:miatracker/LogsTab/ConfirmDialog.dart';
import 'package:miatracker/LogsTab/custom_menu_item.dart';
import 'package:miatracker/Media/edit_media_page.dart';
import 'package:miatracker/Media/new_media_entry.dart';
import 'package:miatracker/Media/new_media_page.dart';
import 'package:miatracker/Models/database.dart';
import 'package:miatracker/Models/media.dart';
import 'package:miatracker/Models/tab_change_notifier.dart';
import 'package:miatracker/Models/user.dart';
import 'package:provider/provider.dart';

import '../Map.dart';

class MediaDisplayPage extends StatefulWidget {
  @override
  _MediaDisplayPageState createState() => _MediaDisplayPageState();
}

class _MediaDisplayPageState extends State<MediaDisplayPage> {
  Category _selectedCategory;
  SortType _selectedSortValue;
  var tapDownDetails;

  @override
  void initState() {
    _selectedSortValue = SortType.lastUpdated;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AppUser>(context);
    var tab = Provider.of<TabChangeNotifier>(context);
    if (user == null || user.categories == null || user.categories.length == 0)
      return Container();

    bool showComplete;
    bool showDropped;
    switch (tab.index) {
      case 0:
        showComplete = false;
        showDropped = false;
        break;
      case 1:
        showComplete = true;
        showDropped = false;
        break;
      case 2:
        showComplete = false;
        showDropped = true;
        break;
      default:
        showComplete = false;
        showDropped = false;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          StreamBuilder<List<Media>>(
              stream: DatabaseService.instance.mediaStream(user,
                  category: _selectedCategory,
                  sortType: _selectedSortValue,
                  showComplete: showComplete,
                  showDropped: showDropped),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.length + 2,
                  itemBuilder: (context, index) {
                    if (index == snapshot.data.length + 1)
                      return Container(height: 100);

                    if (index == 0) {
                      return Wrap(
                        spacing: 10,
                        runSpacing: 0,
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Category', textAlign: TextAlign.left),
                              SizedBox(width: 10),
                              DropdownButton(
                                value: _selectedCategory,
                                items: user.categories
                                    .where((element) => element.isTimeBased)
                                    .map((category) =>
                                        DropdownMenuItem<Category>(
                                          value: category,
                                          child: Text(
                                            category.name,
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ))
                                    .toList()
                                      ..add(DropdownMenuItem<Category>(
                                        value: null,
                                        child: Text('All'),
                                      )),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Sort by',
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(width: 10),
                              DropdownButton(
                                value: _selectedSortValue,
                                items: SortType.values
                                    .map((e) => DropdownMenuItem<SortType>(
                                        value: e,
                                        child: Text(e.name,
                                            style: TextStyle(fontSize: 15))))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSortValue = value;
                                  });
                                },
                              ),
                            ],
                          )
                        ],
                      );
                    }

                    return Card(
                        child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(createSlideRoute(
                            NewMediaEntry(user,
                                media: snapshot.data[index - 1])));
                      },
                      onTapDown: (details) {
                        tapDownDetails = details;
                      },
                      onLongPress: () {
                        showMenu(
                          context: context,
                          position: RelativeRect.fromLTRB(
                              tapDownDetails.globalPosition.dx - 150,
                              tapDownDetails.globalPosition.dy - 40,
                              tapDownDetails.globalPosition.dx,
                              tapDownDetails.globalPosition.dy),
                          items: [
                            CustomMenuItem(
                              value: snapshot.data[index - 1],
                              text: (snapshot.data[index-1].isDropped) ? Text('Un-drop') : Text('Drop'),
                              onPressed: () {
                                snapshot.data[index-1].isDropped = !snapshot.data[index-1].isDropped;
                                DatabaseService.instance.updateMedia(user, snapshot.data[index-1]);
                              },
                            ),
                            CustomMenuItem(
                              value: snapshot.data[index - 1],
                              text: (snapshot.data[index-1].isCompleted) ? Text('Mark as in progress') : Text('Mark as complete'),
                              onPressed: (snapshot.data[index-1].episodeCount != null) ? null : () {
                                snapshot.data[index-1].isCompleted = !snapshot.data[index-1].isCompleted;
                                DatabaseService.instance.updateMedia(user, snapshot.data[index-1]);
                              },
                            ),
                            CustomMenuItem(
                              value: snapshot.data[index - 1],
                              text: Text('Edit'),
                              onPressed: () {
                                Navigator.of(context)
                                    .push(createSlideRoute(EditMediaPage(
                                  user: user,
                                  media: snapshot.data[index - 1],
                                )));
                              },
                            ),
                            CustomMenuItem(
                              value: snapshot.data[index - 1],
                              text: Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () async {
                                bool approved = await asyncConfirmDialog(
                                    context,
                                    title: 'Confirm Delete',
                                    description:
                                        'Delete media? Logs and statistics will remain the same.');
                                if (approved) {
                                  DatabaseService.instance.deleteMedia(
                                      user, snapshot.data[index - 1]);
                                }
                              },
                            )
                          ],
                        );
                      },
                      child: ListTile(
                        title: Text(snapshot.data[index - 1].name),
                        leading: Text(snapshot.data[index - 1].episodeWatchCount
                            .toString()),
                        trailing: Text(convertToStatsDisplay(
                            snapshot.data[index - 1].totalTime)),
                        subtitle: Text(snapshot.data[index - 1].categoryName),
                      ),
                    ));
                  },
                );
              }),
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: MaterialButton(
                onPressed: () =>
                    Navigator.of(context).push(createSlideRoute(NewMediaPage(
                  user: user,
                  initialCategory: _selectedCategory,
                ))),
                shape: RoundedRectangleBorder(
                    side: BorderSide(width: 2, color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Text(
                  '+ New Media',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
