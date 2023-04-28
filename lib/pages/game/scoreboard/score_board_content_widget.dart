import 'dart:async';

import 'package:brot/models/state/member.dart';
import 'package:brot/widgets/brot_animated_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../logger.dart';
import '../../../models/state/user_id.dart';

class ScoreBoardContentWidget extends StatefulWidget {
  const ScoreBoardContentWidget(this.gameKey, {Key? key}) : super(key: key);

  final String gameKey;

  @override
  State<ScoreBoardContentWidget> createState() => _ScoreBoardContentWidgetState();
}

class _ScoreBoardContentWidgetState extends State<ScoreBoardContentWidget> {
  final _list = GlobalKey<AnimatedListStateOf<Member>>();
  late List<StreamSubscription> _subs;

  @override
  void initState() {
    super.initState();
    _subs = [
      FirebaseDatabase.instance
          .ref('/members/${widget.gameKey}')
          .onChildAdded
          .map((event) {
            logI('onChildAdded fired for path {} with value {}',
                ['/members/${widget.gameKey}', '${event.snapshot.value}']);
            return Member.fromJson(event.snapshot.value as Map);
          })
          .where((member) => member.name.isNotEmpty)
          .listen((member) {
            _list.currentState?.insert(member);
          }),
      FirebaseDatabase.instance
          .ref('/members/${widget.gameKey}')
          .onChildRemoved
          .listen((event) {
        logI('onChildRemoved fired for path {} with value {}',
            ['/members/${widget.gameKey}', '${event.snapshot.value}']);
      }),
      FirebaseDatabase.instance
          .ref('/members/${widget.gameKey}')
          .onChildChanged
          .map((event) {
            logI('onChildChanged fired for path {} with value {}',
                ['/members/${widget.gameKey}', '${event.snapshot.value}']);
            return Member.fromJson(event.snapshot.value as Map);
          })
          .where((member) => member.name.isNotEmpty)
          .listen((changedMember) {
            final index = _list.currentState?.items.indexWhere(
                (existingMember) => existingMember.key == changedMember.key);
            if (index != null && index >= 0) {
              logI('member {} already in list, replacing them...',
                  ['$changedMember']);
              setState(() {
                _list.currentState?.items
                    .replaceRange(index, index + 1, [changedMember]);
              });
            } else {
              logI(
                  'member {} does not exist in current member list, inserting them...',
                  ['$changedMember']);
              _list.currentState?.insert(changedMember);
            }
          })
    ];
  }

  @override
  void dispose() {
    super.dispose();
    _subs.forEach((sub) => sub.cancel());
  }

  Widget _itemBuilder(BuildContext context, Member member, bool isSelected) {
    final userId = Provider.of<UserId>(context);

    final isUser = member.userId == userId;
    return Card(
      child: ListTile(
          leading: Icon(Icons.person, color: isUser ? Colors.green : null),
          title: Text(
            member.name,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedListOf<Member>(
      key: _list,
      itemBuilder: _itemBuilder,
    );
  }
}
