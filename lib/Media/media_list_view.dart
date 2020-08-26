import 'package:flutter/material.dart';
import 'package:miatracker/LogsTab/ConfirmDialog.dart';
import 'package:miatracker/LogsTab/custom_menu_item.dart';
import 'package:miatracker/Media/media_selection_model.dart';
import 'package:miatracker/Models/Lifecycle.dart';
import 'package:miatracker/Models/database.dart';
import 'package:miatracker/Models/media.dart';
import 'package:miatracker/Models/shared_preferences.dart';
import 'package:miatracker/Models/tab_change_notifier.dart';
import 'package:miatracker/Models/user.dart';
import 'package:provider/provider.dart';

import '../Map.dart';
import 'edit_media_page.dart';
import 'new_media_entry.dart';

class MediaListView extends StatefulWidget {
  final String watchStatus;
  final bool showComplete;
  final bool showDropped;

  MediaListView({this.showComplete, this.showDropped, this.watchStatus});

  @override
  _MediaListViewState createState() => _MediaListViewState();
}

class _MediaListViewState extends State<MediaListView> with WidgetsBindingObserver {
  var _scrollController = ScrollController();
  var tapDownDetails;
  bool moreDataCalled = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      var user = Provider.of<AppUser>(context, listen: false);
      DatabaseService.instance.refreshMedia(user.uid, widget.watchStatus,
          sortType: MediaSelectionModel.instance.selectedSortTypes[widget.watchStatus],
          showDropped: widget.showDropped,
          showComplete: widget.showComplete);
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    var user = Provider.of<AppUser>(context, listen: false);
    DatabaseService.instance.requestMedia(user.uid, widget.watchStatus,
        sortType: MediaSelectionModel.instance.selectedSortTypes[widget.watchStatus],
        showDropped: widget.showDropped,
        showComplete: widget.showComplete);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mediaSelector = Provider.of<MediaSelectionModel>(context);
    var user = Provider.of<AppUser>(context);
    if (user == null || user.categories == null || user.categories.length == 0)
      return Container();

    return StreamBuilder<List<Media>>(
        stream: DatabaseService.instance.mediaStream(widget.watchStatus),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          return ListView.builder(
            controller: _scrollController..addListener(() {
              var threshold = 0.95 * _scrollController.position.maxScrollExtent;

              if(_scrollController.position.pixels > threshold) {
                if (!moreDataCalled) {
                  DatabaseService.instance.requestMedia(
                      user.uid, widget.watchStatus,
                      sortType: mediaSelector.selectedSortTypes[widget.watchStatus],
                      category: mediaSelector.selectedCategory,
                      showComplete: widget.showComplete,
                      showDropped: widget.showDropped);
                }
                moreDataCalled = true;
              } else moreDataCalled = false;
            }),
            shrinkWrap: true,
            itemCount: snapshot.data.length + 2,
            itemBuilder: (context, index) {
              if (index == snapshot.data.length + 1) {
                return Container(height: 70);
              }

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
                          value: mediaSelector.selectedCategory,
                          items: user.categories
                              .where((element) => element.isTimeBased)
                              .map((category) => DropdownMenuItem<Category>(
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
                            mediaSelector.selectedCategory = value;
                            DatabaseService.instance.refreshMedia(
                                user.uid, widget.watchStatus,
                                showDropped: widget.showDropped,
                                showComplete: widget.showComplete,
                                sortType: mediaSelector.selectedSortTypes[widget.watchStatus],
                                category: mediaSelector.selectedCategory);
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
                          value: mediaSelector.selectedSortTypes[widget.watchStatus],
                          items: SortType.values
                              .map((e) => DropdownMenuItem<SortType>(
                                  value: e,
                                  child: Text(e.name,
                                      style: TextStyle(fontSize: 15))))
                              .toList(),
                          onChanged: (value) {
                            mediaSelector.setSelectedSortType(value, widget.watchStatus);
                            DatabaseService.instance.refreshMedia(
                                user.uid, widget.watchStatus,
                                showDropped: widget.showDropped,
                                showComplete: widget.showComplete,
                                sortType: mediaSelector.selectedSortTypes[widget.watchStatus],
                                category: mediaSelector.selectedCategory);
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
                      NewMediaEntry(user, media: snapshot.data[index - 1])));
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
                        text: (snapshot.data[index - 1].isDropped)
                            ? Text('Un-drop')
                            : Text('Drop'),
                        onPressed: (snapshot.data[index-1].isCompleted) ? null : () {
                          snapshot.data[index - 1].isDropped =
                              !snapshot.data[index - 1].isDropped;
                          DatabaseService.instance
                              .updateMedia(user, snapshot.data[index - 1]);
                        },
                      ),
                      CustomMenuItem(
                        value: snapshot.data[index - 1],
                        text: (snapshot.data[index - 1].isCompleted)
                            ? Text('Mark as in progress')
                            : Text('Mark as complete'),
                        onPressed: (snapshot.data[index - 1].episodeCount !=
                                null)
                            ? null
                            : () {
                                snapshot.data[index - 1].isCompleted =
                                    !snapshot.data[index - 1].isCompleted;
                                snapshot.data[index-1].isDropped = false;

                                if (snapshot.data[index - 1].isCompleted) {
                                  snapshot.data[index - 1].lastUpDate =
                                      DateTime.now();
                                  snapshot.data[index - 1].completeDate =
                                      DateTime.now();
                                }

                                DatabaseService.instance.updateMedia(
                                    user, snapshot.data[index - 1]);
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
                          bool approved = await asyncConfirmDialog(context,
                              title: 'Confirm Delete',
                              description:
                                  'Delete media? Logs and statistics will remain the same.');
                          if (approved) {
                            DatabaseService.instance
                                .deleteMedia(user, snapshot.data[index - 1]);
                          }
                        },
                      )
                    ],
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(snapshot.data[index - 1].name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          snapshot.data[index - 1].episodeWatchCount.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        if(snapshot.data[index-1].episodeCount != null)
                          Text(
                            '/${snapshot.data[index-1].episodeCount}',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Created ${getDate(snapshot.data[index - 1].startDate)}'),
                        Text(
                            'Total time: ${convertToStatsDisplay(snapshot.data[index - 1].totalTime)}')
                      ],
                    ),
                    leading: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          snapshot.data[index - 1].categoryName,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                            color: categoryFromName(
                                    snapshot.data[index - 1].categoryName,
                                    user.categories)
                                .color,
                            width: 40,
                            height: 10)
                      ],
                    ),
                  ),
                ),
              ));
            },
          );
        });
  }
}
