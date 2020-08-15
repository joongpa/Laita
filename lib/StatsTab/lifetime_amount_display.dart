
import 'package:flutter/material.dart';
import 'package:miatracker/Models/user.dart';
import 'package:provider/provider.dart';

class LifetimeAmountDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppUser>(context);
    if(user == null) return Container();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 5,
      runSpacing: 20,
      children:
      List.generate(user.categories.length, (index) {
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
            
          ],
        );
      }),
    );
  }
}
