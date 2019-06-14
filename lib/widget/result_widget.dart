import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ResultWidget extends StatelessWidget {
  final double height;

  ResultWidget({this.height, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.yellow, height: height, child: Text("Result"));
  }
}
