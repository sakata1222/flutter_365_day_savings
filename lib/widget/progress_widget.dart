import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_365_day_savings/dao/saving_state_dao.dart';

class ProgressWidget extends StatelessWidget {
  final ISavingStateDao dao;
  final double height;

  ProgressWidget({this.dao, this.height, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: height),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DaysGrid(
                  dao: dao,
                  height: height,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DaysGrid extends StatefulWidget {
  final ISavingStateDao dao;
  final double height;

  DaysGrid({this.dao, this.height, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DaysGridState(dao: dao, height: height);
  }
}

class DaysGridState extends State<DaysGrid> {
  final ISavingStateDao dao;
  final double height;
  Map<int, bool> _currentState;

  DaysGridState({this.dao, this.height});

  @override
  void initState() {
    dao.currentState().then((result) => setState(() => _currentState = result));
  }

  @override
  Widget build(BuildContext context) {
    if (_currentState == null) {
      return Container();
    }
    var days = new List.generate(365, (i) => i + 1)
        .map((i) => RaisedButton(
            padding: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            onPressed: () => {},
            child: Container(
                padding: EdgeInsets.all(1),
                child: Text(i.toString(),
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                      fontSize: 10.0,
                    )))))
        .toList();
    return Container(
        height: height,
        child: GridView.count(
          primary: false,
          padding: EdgeInsets.all(3),
          childAspectRatio: 2.0,
          mainAxisSpacing: 3,
          crossAxisSpacing: 3,
          crossAxisCount: 10,
          children: days,
        ));
  }
}
//
//class Hogehoge extends StatelessWidget {
//  final ISavingStateDao dao;
//  final double height;
//
//  Hogehoge({this.dao, this.height, Key key}) : super(key: key);
//
//  @override
//  Widget build(BuildContext context) {
//    var days = new List.generate(365, (i) => i + 1)
//        .map((i) => RaisedButton(
//            padding: EdgeInsets.all(0),
//            shape: RoundedRectangleBorder(
//              borderRadius: BorderRadius.all(Radius.circular(10.0)),
//            ),
//            onPressed: () => {},
//            child: Container(
//                padding: EdgeInsets.all(1),
//                child: Text(i.toString(),
//                    textAlign: TextAlign.center,
//                    style: new TextStyle(
//                      fontSize: 10.0,
//                    )))))
//        .toList();
//
//    return Container(
//        height: height,
//        child: GridView.count(
//          primary: false,
//          padding: EdgeInsets.all(3),
//          childAspectRatio: 2.0,
//          mainAxisSpacing: 3,
//          crossAxisSpacing: 3,
//          crossAxisCount: 10,
//          children: days,
//        ));
//  }
//}
