import 'dart:async';

import 'package:brot/models/state/word.dart';
import 'package:brot/widgets/brot_animated_list.dart';
import 'package:brot/widgets/suited_loading_spinner_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class WordsWidget extends StatefulWidget {
  const WordsWidget(this.gameKey, {Key? key}) : super(key: key);

  final String gameKey;

  @override
  State<WordsWidget> createState() => _WordsWidgetState();
}

class _WordsWidgetState extends State<WordsWidget> {
  final _listKey = GlobalKey<AnimatedListStateOf<Word>>();
  late AnimatedListStateOf<Word> _list;

  // late AnimatedListOf<Member> _list;
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
        _list.insert(Word.fromJson(event.snapshot.value as Map));
      }),
      FirebaseDatabase.instance
          .ref('/words/${widget.gameKey}')
          .onChildChanged
          .listen((event) {})
    ];
  }

  @override
  void dispose() {
    super.dispose();
    _subs.forEach((sub) => sub.cancel());
  }

  Widget _itemBuilder(BuildContext context, Word word) {
    final theme = Theme.of(context);
    return Card(
        child: ListTile(
            title: Text(
      word.value,
      style: theme.textTheme.titleMedium,
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
          return SuitedLoadingSpinner(
              color: Theme.of(context).colorScheme.onPrimary);
        }
      },
    );
  }
}
