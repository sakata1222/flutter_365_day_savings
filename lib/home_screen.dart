import 'dart:async';

import 'package:flutter/material.dart';

import 'dao/saving_state_dao.dart';
import 'widget/progress_widget.dart';
import 'widget/register_money_widget.dart';

class HomeScreen extends StatelessWidget {
  final ISavingStateDao dao;
  final EventSink<Map<int, bool>> latestDataStreamConsumer;
  final Stream<Map<int, bool>> latestDataStream;

  HomeScreen({this.dao, this.latestDataStreamConsumer, this.latestDataStream});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      double progressAreaHeight = 40;
      double borderSpace = 5;
      double daysWidgetHeight =
          viewportConstraints.maxHeight - progressAreaHeight - borderSpace;
      return Align(
        alignment: Alignment.topCenter,
        child: ListView(
          padding: EdgeInsets.only(left: 8, right: 8),
          children: <Widget>[
            ProgressWidget(
              latestDataStream: latestDataStream,
              height: progressAreaHeight,
            ),
            Padding(
                padding: EdgeInsets.only(bottom: borderSpace),
                child: RegisterMoneyWidget(
                  dao: dao,
                  latestDataStreamConsumer: latestDataStreamConsumer,
                  latestDataStream: latestDataStream,
                  height: daysWidgetHeight,
                )),
          ],
        ),
      );
    });
  }
}
