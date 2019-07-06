import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_365_day_savings/dao/saving_state_dao.dart';

class RegisterMoneyWidget extends StatefulWidget {
  final ISavingStateDao dao;
  final EventSink<Map<int, bool>> latestDataStreamConsumer;
  final Stream<Map<int, bool>> latestDataStream;
  final double height;

  RegisterMoneyWidget(
      {this.dao,
      this.latestDataStreamConsumer,
      this.latestDataStream,
      this.height,
      Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new RegisterMoneyState(
        dao: dao,
        latestDataStreamConsumer: latestDataStreamConsumer,
        latestDataStream: latestDataStream,
        height: height);
  }
}

class RegisterMoneyState extends State<RegisterMoneyWidget> {
  final ISavingStateDao dao;
  final EventSink<Map<int, bool>> latestDataStreamConsumer;
  final Stream<Map<int, bool>> latestDataStream;
  final double height;

  Map<int, bool> _pressed;

  int crossAxisCount = 10;
  double buttonTextSize = 10;

  RegisterMoneyState(
      {this.dao,
      this.latestDataStreamConsumer,
      this.latestDataStream,
      this.height});

  @override
  void initState() {
    super.initState();
    _pressed = Map();
  }

  VoidCallback buildAnPressedAction(int i, bool isSaved) {
    if (isSaved) {
      return () => {};
    }
    if (!_pressed.containsKey(i)) {
      return () => setState(() => {_pressed[i] = true});
    }
    return () => setState(() => {_pressed[i] = !_pressed[i]});
  }

  Color decideColor(int i, bool isSaved) {
    if (isSaved) {
      return Colors.amber[800];
    }
    if (!_pressed.containsKey(i)) {
      return null;
    }
    if (_pressed[i]) {
      return Colors.amber[200];
    } else {
      return null;
    }
  }

  String buildButtonText(int i, bool isSaved) {
    if (isSaved) {
      return 'Done';
    }
    return i.toString();
  }

  @override
  Widget build(BuildContext context) {
    double selectionResultArea = 30;

    return GestureDetector(
        onScaleUpdate: (scaleDetails) {
          setState(() {
            if (scaleDetails.scale >= 1.3) {
              crossAxisCount = 5;
              buttonTextSize = 20;
            }
            if (scaleDetails.scale <= 0.7) {
              crossAxisCount = 10;
              buttonTextSize = 10;
            }
          });
        },
        child: StreamBuilder<Map<int, bool>>(
          stream: latestDataStream,
          builder: (context, asyncSnapshot) {
            if (!asyncSnapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            var currentState = asyncSnapshot.data;
            var days = new List.generate(365, (i) => i + 1)
                .map((i) => RaisedButton(
                    padding: EdgeInsets.only(top: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    onPressed: buildAnPressedAction(i, currentState[i]),
                    color: decideColor(i, currentState[i]),
                    child: Container(
                        padding: EdgeInsets.all(1),
                        child: Text(buildButtonText(i, currentState[i]),
                            textAlign: TextAlign.center,
                            style: new TextStyle(
                              fontSize: buttonTextSize,
                            )))))
                .toList();

            int selectedCount;
            int totalSaving;
            if (_pressed.isEmpty) {
              selectedCount = 0;
              totalSaving = 0;
            } else {
              selectedCount = _pressed.entries.where((e) => e.value).length;
              if (selectedCount > 0) {
                totalSaving = _pressed.entries
                    .where((e) => e.value)
                    .map((e) => e.key)
                    .reduce((v1, v2) => v1 + v2);
              } else {
                totalSaving = 0;
              }
            }

            return LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                return Container(
                    padding: EdgeInsets.all(0),
                    margin: EdgeInsets.all(0),
                    height: height,
                    child: ListView(children: <Widget>[
                      SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: height),
                          child: Container(
                            height: height - selectionResultArea,
                            child: GridView.count(
                              primary: false,
                              padding: EdgeInsets.all(3),
                              childAspectRatio: 2.0,
                              mainAxisSpacing: 3,
                              crossAxisSpacing: 3,
                              crossAxisCount: crossAxisCount,
                              children: days,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(0),
                        margin: EdgeInsets.all(0),
                        height: selectionResultArea,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Expanded(
                                child: Text('Selected : ' +
                                    selectedCount.toString() +
                                    ' days')),
                            Expanded(
                                child: Center(
                                    child: Text(
                                        '\u00A5' + totalSaving.toString()))),
                            Padding(
                                padding: EdgeInsets.all(4),
                                child: RaisedButton(
                                  color: Colors.amber[800],
                                  onPressed: () => {
                                        setState(() {
                                          dao.updateState(_pressed).then((v) =>
                                              dao.currentState().then(
                                                  (result) => setState(() {
                                                        _pressed.clear();
                                                        latestDataStreamConsumer
                                                            .add(result);
                                                      })));
                                        })
                                      },
                                  child: Text('Save Money'),
                                ))
                          ],
                        ),
                      )
                    ]));
              },
            );
          },
        ));
  }
}
