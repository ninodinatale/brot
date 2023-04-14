import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Dot3ProgressIndicator extends StatefulWidget {
  Dot3ProgressIndicator(
      {Key? key,
      String prefix = '',
      int numberPeriods = 3,
      TextStyle? textStyle})
      : _prefix = prefix,
        _numberPeriods = numberPeriods,
        _textStyle = textStyle,
        super(key: key);

  final String _prefix;
  final int _numberPeriods;
  final TextStyle? _textStyle;

  @override
  _Dot3ProgressIndicatorState createState() => _Dot3ProgressIndicatorState();
}

class _Dot3ProgressIndicatorState extends State<Dot3ProgressIndicator> {
  String _dots = '';
  late Timer _timer;
  final GlobalKey _key = GlobalKey();
  double? _width;

  void _postFrameCallback(_) {
    if (_width != null) return;

    var context = _key.currentContext;
    if (context == null) return;

    _width = context.size?.width;
  }

  @override
  void initState() {
    super.initState();

    Iterable<int>.generate(widget._numberPeriods).toList().forEach((element) {
      _dots += '.';
    });

    SchedulerBinding.instance.addPostFrameCallback(_postFrameCallback);

    _timer = Timer.periodic(
        const Duration(milliseconds: 500),
        (Timer t) => setState(() {
              if (_dots.length >= widget._numberPeriods) {
                _dots = '';
              } else {
                _dots += '.';
              }
            }));
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      child: RichText(
          key: _key,
          textWidthBasis: TextWidthBasis.longestLine,
          text: TextSpan(style: widget._textStyle, children: [
            TextSpan(text: widget._prefix),
            TextSpan(text: _dots)
          ])),
    );
  }
}
