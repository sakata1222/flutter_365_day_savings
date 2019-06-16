// Flutter code sample for material.Card.2

// This sample shows creation of a [Card] widget that can be tapped. When
// tapped this [Card]'s [InkWell] displays an "ink splash" that fills the
// entire card.

import 'dart:async';

import 'package:flutter/material.dart';

import 'dao/saving_state_dao.dart';
import 'home_screen.dart';

void main() => runApp(MyApp());

final String _title = '365 day savings';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.amber),
      title: _title,
      home: MainScreen(),
    );
  }
}

/// This Widget is the main application widget.
class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    ISavingStateDao dao = SavingStateDaoSqfliteImpl();
    return new MainScreenState(dao: dao);
  }
}

class MainScreenState extends State<MainScreen> {
  final ISavingStateDao dao;
  StreamController<Map<int, bool>> latestDataStreamController =
      new StreamController<Map<int, bool>>();

  MainScreenState({this.dao});

  @override
  void initState() {
    super.initState();
    dao.init().then((v) => dao.currentState()).then((v) => setState(() {
          latestDataStreamController.add(v);
        }));
  }

  @override
  Widget build(BuildContext context) {
    Stream<Map<int, bool>> latestDataStream =
        latestDataStreamController.stream.asBroadcastStream();
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(40.0),
          child: AppBar(
            title: Text(_title),
            actions: <Widget>[
              new PopupMenuButton(
                  onSelected: (PopupMenuAction action) =>
                      action.action(context, dao, latestDataStreamController),
                  itemBuilder: (BuildContext context) => [
                        PopupMenuItem<PopupMenuAction>(
                            child: Text('Reset All'), value: restAllAction)
                      ]),
            ],
          )),
      body: body(latestDataStream),
    );
  }

  @override
  void dispose() {
    latestDataStreamController.close();
  }

  Widget body(Stream<Map<int, bool>> latestDataStream) {
    if (dao.initializeCompleted()) {
      return HomeScreen(
        dao: dao,
        latestDataStreamConsumer: latestDataStreamController,
        latestDataStream: latestDataStream,
      );
    }
    return Center(child: CircularProgressIndicator());
  }
}

class PopupMenuAction {
  final String name;

  final PopMenuSectionAction action;

  PopupMenuAction({this.name, this.action});
}

typedef PopMenuSectionAction = void Function(
    BuildContext context,
    ISavingStateDao dao,
    StreamController<Map<int, bool>> latestDataStreamController);

var restAllAction = PopupMenuAction(
  name: 'Reset',
  action: (context, dao, latestDataStreamController) => {
        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  title: Text('Confirmation'),
                  content: Text('Are you sure  you want to Reset All data?'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Reset All'),
                      onPressed: () {
                        dao.deleteAllRecords().then((v) {
                          return dao
                              .currentState()
                              .then((current) =>
                                  latestDataStreamController.add(current))
                              .catchError((e) => print(e));
                        }).then((v) => Navigator.pop(context));
                      },
                    )
                  ],
                ))
      },
);
