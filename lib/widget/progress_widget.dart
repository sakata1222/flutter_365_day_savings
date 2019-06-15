import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_365_day_savings/dao/saving_state_dao.dart';

class ProgressWidget extends StatefulWidget {
  final ISavingStateDao dao;
  final double height;

  ProgressWidget({this.dao, this.height, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ProgressState(dao: dao, height: height);
  }
}

class ProgressState extends State<ProgressWidget> {
  final ISavingStateDao dao;
  double height;

  Map<int, bool> _currentState;

  ProgressState({this.dao, this.height});

  @override
  void initState() {
    dao.currentState().then((result) => setState(() => _currentState = result));
  }

  @override
  Widget build(BuildContext context) {
    if (_currentState == null) {
      return Center(child: CircularProgressIndicator());
    }
    int allCount = _currentState.values.length;
    int savedCount =
        _currentState.values.where((saved) => saved == true).length;
    int totalSaved = savedCount > 0
        ? _currentState.entries
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
  }
}
