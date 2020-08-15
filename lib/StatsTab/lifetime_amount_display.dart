import 'package:flutter/material.dart';
import 'package:miatracker/Map.dart';
import 'package:miatracker/Models/aggregate_data_model.dart';
import 'package:miatracker/Models/user.dart';
import 'package:provider/provider.dart';

class LifetimeAmountDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppUser>(context);
    DailyInputEntry firstEntry = Provider.of<DailyInputEntry>(context);
    if (user == null || firstEntry == null) return Container();

    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 5,
          runSpacing: 20,
          children: List.generate(user.categories.length, (index) {
            return Column(
              children: <Widget>[
                Container(
                  width: 80,
                  child: Text(
                    user.categories[index].name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                _getWidget(_convertToDisplay(
                    user.categories[index].lifetimeAmount,
                    user.categories[index].isTimeBased),
                    user.categories[index].isTimeBased),
              ],
            );
          }),
        ),
        SizedBox(height: 15),
        Row(
          children: [
            Expanded(
                child: Text(
              'Start Date',
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.grey),
            )),
            SizedBox(width: 10),
            Expanded(
              child: Text(getDate(firstEntry.dateTime)),
            )
          ],
        )
      ],
    );
  }

  String _convertToDisplay(double value, bool isTimeBased) {
    if (isTimeBased) {
      return (value >= 100)
          ? value.toInt().toString()
          : UsefulShit.singleDecimalFormat.format(value);
    } else {
      return value.toInt().toString();
    }
  }

  Widget _getWidget(String text, bool isTimeBased) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
          ),
        ),
        Text(isTimeBased ? 'hours' : 'amount',
            style: TextStyle(color: Colors.grey, fontSize: 15)),
      ],
    );
  }
}
