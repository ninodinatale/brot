import 'dart:async';

import 'package:brot/database.dart';
import 'package:brot/models/state/word.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../logger.dart';
import '../../../models/state/member.dart';
import '../../../models/state/user_id.dart';
import '../../../widgets/animated_flash.dart';
import '../../../widgets/animated_int_widget.dart';
import '../../../widgets/brot_animated_list.dart';

class IsNotBreadVotingWordsContentWidget extends StatefulWidget {
  IsNotBreadVotingWordsContentWidget({Key? key, required this.gameKey})
      : super(key: key);

  final String gameKey;

  @override
  State<IsNotBreadVotingWordsContentWidget> createState() =>
      _IsNotBreadVotingWordsContentWidgetState();
}

class _IsNotBreadVotingWordsContentWidgetState
    extends State<IsNotBreadVotingWordsContentWidget> {
  final _list = GlobalKey<AnimatedListStateOf<Word>>();

  late List<StreamSubscription> _subs;

  @override
  void initState() {
    super.initState();
    _subs = [
      FirebaseDatabase.instance
          .ref('/words/${widget.gameKey}')
          .onChildAdded
          .listen((event) {
        logI('onChildAdded fired for path {} with value {}',
            ['/words/${widget.gameKey}', '${event.snapshot.value}']);
        _list.currentState?.insert(Word.fromJson(event.snapshot.value as Map));
      }),
      FirebaseDatabase.instance
          .ref('/words/${widget.gameKey}')
          .onChildChanged
          .listen((event) {
        logI('onChildChanged fired for path {} with value {}',
            ['/words/${widget.gameKey}', '${event.snapshot.value}']);
        final changedWord = Word.fromJson(event.snapshot.value as Map);
        final index = _list.currentState?.items.indexWhere(
                (existingWord) => existingWord.value == changedWord.value) ??
            -1;
        if (index >= 0) {
          setState(() {
            _list.currentState?.items
                .replaceRange(index, index + 1, [changedWord]);
          });
        } else {
          logE(
              'word $changedWord does not exist in current word list - cannot update');
        }
      })
    ];
  }

  void _voteForWord(Word item, int index) {
    _list.currentState?.selectIndex(index);
    showModalBottomSheet<void>(
        isDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) => Container(
              height: 200,
              color: Theme.of(context).colorScheme.background,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text('Modal BottomSheet'),
                    ElevatedButton(
                      child: Text('Für "${item.value}" voten'),
                      onPressed: () {
                        voteForWord(
                            item, context.read<UserId>());
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      child: Text('Abbrechen'),
                      onPressed: () {
                        _list.currentState?.deselect();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    _subs.forEach((sub) => sub.cancel());
    super.dispose();
  }

  Widget _itemBuilder(BuildContext context, Word word, bool isSelected) {
    final theme = Theme.of(context);
    return Card(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.5)
                : Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(3))),
        child: AnimatedFlash(
            value: word.votes,
            child: ListTile(
              leading: const Icon(Icons.abc),
              title: Text(
                word.value,
                style: theme.textTheme.titleLarge!,
              ),
              trailing: AnimatedInt(
                  value: word.votes, textStyle: theme.textTheme.titleLarge),
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userMember = Provider.of<Member>(context);
    return AnimatedListOf<Word>(
      onTap: (item, index) =>
          userMember.hasVotedForWord ? null : _voteForWord(item, index),
      key: _list,
      itemBuilder: _itemBuilder,
    );
  }
}
