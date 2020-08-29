import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/Media/media_list_view.dart';
import 'package:miatracker/Media/new_media_page.dart';
import 'package:miatracker/Models/error_handling_model.dart';
import 'package:miatracker/Models/tab_change_notifier.dart';
import 'package:miatracker/Models/user.dart';
import 'package:provider/provider.dart';
import '../Map.dart';

class MediaDisplayPage extends StatefulWidget {
  final snackBar = SnackBar(content: Text('Something went wrong. Please try again'), duration: Duration(seconds: 1, milliseconds: 500),);

  @override
  _MediaDisplayPageState createState() => _MediaDisplayPageState();
}

class _MediaDisplayPageState extends State<MediaDisplayPage> {
  var errorStream;

  @override
  void initState() {
    super.initState();
    errorStream ??= ErrorHandlingModel.instance.hasError.listen((hasError) {
      if(hasError) Scaffold.of(context).showSnackBar(widget.snackBar);
    });
  }

  @override
  void dispose() {
    errorStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AppUser>(context);
    var tab = Provider.of<TabChangeNotifier>(context);
    if (user == null || user.categories == null || user.categories.length == 0)
      return Container();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          IndexedStack(
            index: tab.index ?? 0,
            children: [
              MediaListView(
                showComplete: false,
                showDropped: false,
                watchStatus: 'In Progress',
              ),
              MediaListView(
                showComplete: true,
                showDropped: false,
                watchStatus: 'Complete',
              ),
              MediaListView(
                showComplete: false,
                showDropped: true,
                watchStatus: 'Dropped',
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: MaterialButton(
                onPressed: () {
                  Navigator.of(context).push(createSlideRoute(NewMediaPage(
                    user: user,
                  )));
                },
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
