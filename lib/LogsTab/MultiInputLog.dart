import 'package:flutter/material.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';

import '../Map.dart';
import 'InputLog.dart';

class MultiInputLog extends StatefulWidget {
  @override
  _MultiInputLogState createState() => _MultiInputLogState();
}

class _MultiInputLogState extends State<MultiInputLog> {
  PageController controller;
  int page = 0;
  final DateTime startingDatePage = DateTime(2020, 7, 1);
  int itemCount = 0;

  @override
  void initState() {
    super.initState();
    itemCount = daysBetween(startingDatePage, DateTime.now()) + 1;
    controller = PageController(initialPage: itemCount);
    controller.addListener(() {
      if (controller.page.round() != page) {
        setState(() {
          page = controller.page.round();
        });
      }
    });

    InputHoursUpdater.ihu.updateStream$.listen((data) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    itemCount = daysBetween(startingDatePage, DateTime.now()) + 1;
    return StreamBuilder(
      stream: InputHoursUpdater.ihu.updateStream$,
      builder: (context, snapshot) {
        return Column(
          children: <Widget>[
            Expanded(
              child: PageView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  itemCount: itemCount,
                  itemBuilder: (context, page) {
                    return InputLog(dateTime: daysAgo(-page, startingDatePage));
                  }
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[300],
                    blurRadius: 5.0, // has the effect of softening the shadow
                    spreadRadius: 5.0, // has the effect of extending the shadow
                    offset: Offset(
                      1.0, // horizontal, move right 10
                      1.0, // vertical, move down 10
                    ),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      onPressed: page == 0
                          ? null
                          : () {
                        controller.jumpToPage(controller.page.round() - 1);
                      },
                      child: const Icon(
                        Icons.chevron_left,
                        size: 40,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      getDate(daysAgo(-page, startingDatePage)),
                      //getDate(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20
                      ),
                    ),
                  ),
                  Expanded(
                    child: FlatButton(
                      onPressed: page == daysBetween(startingDatePage, DateTime.now())
                          ? null
                          : () {
                        controller.jumpToPage(controller.page.round() + 1);
                      },
                      child: const Icon(
                        Icons.chevron_right,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
