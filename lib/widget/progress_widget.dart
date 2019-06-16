import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressWidget extends StatelessWidget {
  final Stream<Map<int, bool>> latestDataStream;
  final double height;

  ProgressWidget({this.latestDataStream, this.height});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<int, bool>>(
      stream: latestDataStream,
      builder: (context, asyncSnapshot) {
        if (!asyncSnapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        var currentState = asyncSnapshot.data;
        int allCount = currentState.values.length;
        int savedCount =
            currentState.values.where((saved) => saved == true).length;
        int totalSaved = savedCount > 0
            ? currentState.entries
                .where((entry) => entry.value == true)
                .map((entry) => entry.key)
                .reduce((v1, v2) => v1 + v2)
            : 0;
        double progress = savedCount.toDouble() / allCount;
        double padding = 0;
        return Container(
            height: height - (padding * 2),
            padding: EdgeInsets.all(padding),
            margin: EdgeInsets.all(0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Expanded(
                    child: Row(
                  children: <Widget>[
                    Text('Progress :'),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.only(left: 3, right: 5),
                            child: SizedBox(
                                height: 10,
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.black12,
                                  value: progress,
                                )))),
                    Text(savedCount.toString() + ' / ' + allCount.toString()),
                  ],
                )),
                Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text('\u00A5' + totalSaved.toString())),
              ],
            ));
      },
    );
  }
}
