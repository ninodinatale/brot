import 'dart:async';

import 'package:brot/models/state/word.dart';
import 'package:brot/widgets/brot_animated_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../../logger.dart';

class WordsWidget extends StatefulWidget {
  const WordsWidget(this.gameKey, {Key? key}) : super(key: key);

  final String gameKey;

  @override
  State<WordsWidget> createState() => _WordsWidgetState();
}

class _WordsWidgetState extends State<WordsWidget> {
  final _listKey = GlobalKey<AnimatedListStateOf<Word>>();
  late AnimatedListStateOf<Word> _list;

  late List<StreamSubscription> _subs;

  @override
  void initState() {
    super.initState();
    _list = _listKey.currentState!;
    _subs = [
      FirebaseDatabase.instance
          .ref('/words/${widget.gameKey}')
          .onChildAdded
          .listen((event) {
        logI('onChildAdded fired for path {} with value {}',
            ['/words/${widget.gameKey}', '${event.snapshot.value}']);
        _list.insert(Word.fromJson(event.snapshot.value as Map));
      }),
      FirebaseDatabase.instance
          .ref('/words/${widget.gameKey}')
          .onChildChanged
          .listen((event) {
        logI('onChildChanged fired for path  with value {}',
            ['/words/${widget.gameKey}', '${event.snapshot.value}']);
      }),
      FirebaseDatabase.instance
          .ref('/words/${widget.gameKey}')
          .onValue
          .listen((event) {
        logI('onValue fired for path {} with value {}',
            ['/words/${widget.gameKey}', '${event.snapshot.value}']);
      })
    ];
  }

  @override
  void dispose() {
    super.dispose();
    _subs.forEach((sub) => sub.cancel());
  }

  Widget _itemBuilder(BuildContext context, Word word, bool isSelected) {
    return Card(

        child: ListTile(
            selected: isSelected,
            title: Text(
              word.value,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseDatabase.instance.ref('/words/${widget.gameKey}').get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return AnimatedListOf<Word>(
            key: _listKey,
            itemBuilder: _itemBuilder,
          );
        } else {
          return CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onPrimary);
        }
      },
    );
  }
}
