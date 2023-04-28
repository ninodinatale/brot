import 'package:brot/main.dart';
import 'package:flutter/material.dart';

class ScoreboardHeaderWidget extends StatefulWidget {
  const ScoreboardHeaderWidget({Key? key}) : super(key: key);

  @override
  _ScoreboardHeaderWidgetState createState() => _ScoreboardHeaderWidgetState();
}

class _ScoreboardHeaderWidgetState extends State<ScoreboardHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Scoreboard', style: Theme.of(context).textTheme.header1),
        Text('Round ', style: Theme.of(context).textTheme.header2),
      ],
    );
  }
}
