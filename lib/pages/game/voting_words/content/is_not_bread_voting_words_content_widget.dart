import 'dart:async';

import 'package:brot/firebase_functions.dart';
import 'package:brot/models/payload/payloads.dart';
import 'package:brot/models/state/word.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../logger.dart';
import '../../../../models/state/user_id.dart';
import '../../../../widgets/animated_flash.dart';
import '../../../../widgets/animated_int_widget.dart';
import '../../../../widgets/bottom_sheet_modal.dart';
import '../../../../widgets/brot_animated_list.dart';

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
    brotModalBottomSheet<void>(
      context: context,
      child: StatefulBuilder(
        builder: (context, setState) => Row(
          children: <Widget>[
            TextButton(
              child: Text('Abbrechen'),
              onPressed: () {
                _list.currentState?.deselect();
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            FilledButton(
              child: Text('Für "${item.value}" voten'),
              onPressed: () {
                BrotFirebaseFunctions.callVoteForWord(VoteWordPayload(
                        userId: context.read<UserId>(),
                        gameKey: item.gameKey,
                        wordKey: item.key));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subs.forEach((sub) => sub.cancel());
    super.dispose();
  }

  Widget _itemBuilder(BuildContext context, Word word, bool isSelected) {
    return ShakeOnChange(
      triggerValue: word.votes,
      child: Card(
        child: ListTile(
          selected: isSelected,
          leading: const Icon(Icons.abc),
          title: Text(
            word.value,
          ),
          trailing: AnimatedInt(
              value: word.votes,
              textStyle: Theme.of(context).textTheme.titleMedium),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userHasVotedForWord = Provider.of<UserHasVotedForWord>(context);
    return AnimatedListOf<Word>(
      onTap: (item, index) =>
          userHasVotedForWord.value ? null : _voteForWord(item, index),
      key: _list,
      itemBuilder: _itemBuilder,
    );
  }
}
