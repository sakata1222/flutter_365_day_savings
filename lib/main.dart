// Flutter code sample for material.Card.2

// This sample shows creation of a [Card] widget that can be tapped. When
// tapped this [Card]'s [InkWell] displays an "ink splash" that fills the
// entire card.

import 'package:flutter/material.dart';

import 'dao/saving_state_dao.dart';
import 'widget/progress_widget.dart';
import 'widget/result_widget.dart';

void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = '365 day savings';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: Text(_title)),
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
      double resultAreaHeight = 50;
      double progressAreaHeight =
          viewportConstraints.maxHeight - resultAreaHeight;
      return Align(
        alignment: Alignment.topCenter,
        child: ListView(
          padding: const EdgeInsets.all(8.0),
          children: <Widget>[
            ProgressWidget(
              dao: dao,
              height: progressAreaHeight,
            ),
            ResultWidget(height: resultAreaHeight),
          ],
        ),
      );
    });
  }
}

/// This is the stateless widget that the main application instantiates.
class MyStatelessWidget extends StatelessWidget {
  MyStatelessWidget({Key key}) : super(key: key);
  ISavingStateDao dao = SavingStateDaoSqfliteImpl();

  @override
  Widget build(BuildContext context) {
    dao.init();
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      double resultAreaHeight = 50;
      double progressAreaHeight =
          viewportConstraints.maxHeight - resultAreaHeight;
      return Align(
        alignment: Alignment.topCenter,
        child: ListView(
          padding: const EdgeInsets.all(8.0),
          children: <Widget>[
            ProgressWidget(
              dao: dao,
              height: progressAreaHeight,
            ),
            ResultWidget(height: resultAreaHeight),
          ],
        ),
      );
    });
  }
}
