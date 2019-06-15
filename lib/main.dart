// Flutter code sample for material.Card.2

// This sample shows creation of a [Card] widget that can be tapped. When
// tapped this [Card]'s [InkWell] displays an "ink splash" that fills the
// entire card.

import 'package:flutter/material.dart';
import 'package:flutter_365_day_savings/widget/days_widget.dart';

import 'dao/saving_state_dao.dart';
import 'widget/progress_widget.dart';

void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = '365 day savings';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(30.0),
            child: AppBar(title: Text(_title))),
        body: ApplicationWidget(),
      ),
    );
  }
}

class ApplicationWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ApplicationState();
  }
}

class ApplicationState extends State<ApplicationWidget> {
  ISavingStateDao dao = SavingStateDaoSqfliteImpl();
  bool isInitialized = false;

  @override
  void initState() {
    dao.init().then((v) => setState(() => isInitialized = true));
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return Center(child: CircularProgressIndicator());
    }
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      double progressAreaHeight = 20;
      double borderSpace = 5;
      double daysWidgetHeight =
          viewportConstraints.maxHeight - progressAreaHeight - borderSpace;
      return Align(
        alignment: Alignment.topCenter,
        child: ListView(
          padding: EdgeInsets.only(left: 8, right: 8),
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(bottom: borderSpace),
                child: DaysWidget(
                  dao: dao,
                  height: daysWidgetHeight,
                )),
            ProgressWidget(dao: dao, height: progressAreaHeight),
          ],
        ),
      );
    });
  }
}
