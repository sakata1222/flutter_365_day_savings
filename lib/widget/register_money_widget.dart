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

class GridSize {
  int index;
  int crossAxisCount;
  double buttonTextSize;

  GridSize({this.index, this.crossAxisCount, this.buttonTextSize});

  double adjustOffset(double currentOffset, GridSize previous) {
    int previousRow = 365 ~/ previous.crossAxisCount + 1;
    int nextRow = 365 ~/ this.crossAxisCount + 1;
    return currentOffset * nextRow / previousRow;
  }
}

class RegisterMoneyState extends State<RegisterMoneyWidget> {
  static final List<GridSize> sizeList = [
    GridSize(index: 0, crossAxisCount: 15, buttonTextSize: 6),
    GridSize(index: 1, crossAxisCount: 10, buttonTextSize: 10),
    GridSize(index: 2, crossAxisCount: 7, buttonTextSize: 12),
    GridSize(index: 3, crossAxisCount: 5, buttonTextSize: 20),
  ];

  final ISavingStateDao dao;
  final EventSink<Map<int, bool>> latestDataStreamConsumer;
  final Stream<Map<int, bool>> latestDataStream;
  final double height;

  Map<int, bool> _pressed;
  ScrollController scrollController;

  GridSize currentSize = sizeList[1];
  int lastSizeChanged = 0;

  RegisterMoneyState(
      {this.dao,
      this.latestDataStreamConsumer,
      this.latestDataStream,
      this.height});

  @override
  void initState() {
    super.initState();
    _pressed = Map();
    scrollController =
        ScrollController(initialScrollOffset: 0, keepScrollOffset: false);
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

    return StreamBuilder<Map<int, bool>>(
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
                          fontSize: currentSize.buttonTextSize,
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
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return Container(
                padding: EdgeInsets.all(0),
                margin: EdgeInsets.all(0),
                height: height,
                child: ListView(children: <Widget>[
                  GestureDetector(
                    onScaleUpdate: (scaleDetails) {
                      setState(() {
                        if (isSameGesture()) {
                          return;
                        }
                        lastSizeChanged = DateTime.now().millisecondsSinceEpoch;
                        var previousSize = currentSize;
                        if (scaleDetails.scale >= 1.1) {
                          currentSize = pinchIn(previousSize);
                        }
                        if (scaleDetails.scale <= 0.9) {
                          currentSize = pinchOut(previousSize);
                        }
                        var adjustedPosition = currentSize.adjustOffset(
                            scrollController.offset, previousSize);
                        scrollController.jumpTo(adjustedPosition);
                      });
                    },
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: height),
                      child: Container(
                        height: height - selectionResultArea,
                        child: GridView.count(
                          controller: scrollController,
                          primary: false,
                          padding: EdgeInsets.all(3),
                          childAspectRatio: 2.0,
                          mainAxisSpacing: 3,
                          crossAxisSpacing: 3,
                          crossAxisCount: currentSize.crossAxisCount,
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
                                child:
                                    Text('\u00A5' + totalSaving.toString()))),
                        Padding(
                            padding: EdgeInsets.all(4),
                            child: RaisedButton(
                              color: Colors.amber[800],
                              onPressed: () => {
                                setState(() {
                                  dao.updateState(_pressed).then((v) => dao
                                      .currentState()
                                      .then((result) => setState(() {
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
    );
  }

  bool isSameGesture() {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    // ignore event after 900 milli sec after size changed
    return lastSizeChanged + 900 > currentTime;
  }

  GridSize pinchIn(GridSize current) {
    if (current.index + 1 < sizeList.length) {
      return sizeList[current.index + 1];
    }
    return current;
  }

  GridSize pinchOut(GridSize current) {
    if (current.index - 1 >= 0) {
      return sizeList[current.index - 1];
    }
    return current;
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }
}
