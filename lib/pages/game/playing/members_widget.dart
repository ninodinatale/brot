import 'dart:async';

import 'package:brot/constants.dart';
import 'package:brot/models/state/member.dart';
import 'package:brot/widgets/brot_animated_list.dart';
import 'package:brot/widgets/dot3_progress_indicator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MembersWidget extends StatefulWidget {
  const MembersWidget(this.gameKey, {Key? key}) : super(key: key);

  final String gameKey;

  @override
  State<MembersWidget> createState() => _MembersWidgetState();
}

class _MembersWidgetState extends State<MembersWidget> {
  final _listKey = GlobalKey<AnimatedListStateOf<Member>>();
  late AnimatedListStateOf<Member> _list;

  // late AnimatedListOf<Member> _list;
  late List<StreamSubscription> _subs;

  @override
  void initState() {
    super.initState();
    _list = _listKey.currentState!;
    _subs = [
      FirebaseDatabase.instance
          .ref('/members/${widget.gameKey}')
          .onChildAdded
          .listen((event) {
        _list.insert(Member.fromJson(event.snapshot.value as Map));
      }),
      FirebaseDatabase.instance
          .ref('/members/${widget.gameKey}')
          .onChildRemoved
          .listen((event) {}),
      FirebaseDatabase.instance
          .ref('/members/${widget.gameKey}')
          .onChildChanged
          .listen((event) {
        final changedMember = Member.fromJson(event.snapshot.value as Map);
        final index = _list.items.indexWhere(
            (existingMember) => existingMember.key == changedMember.key);
        if (index >= 0) {
          setState(() {
            _list.items.replaceRange(index, index + 1, [changedMember]);
          });
        } else {
          blog.e(
              'member $changedMember does not exist in current member list - cannot update');
        }
      })
    ];
  }

  @override
  void dispose() {
    super.dispose();
    _subs.forEach((sub) => sub.cancel());
  }

  Widget _itemBuilder(BuildContext context, Member member) {
    final theme = Theme.of(context);
    final hasName = member.name != '';
    return Card(
      child: ListTile(
          leading: Icon(Icons.person, color: hasName ? Colors.green : null),
          title: !hasName
              ? Dot3ProgressIndicator(
                  prefix: 'tritt bei',
                  textStyle: theme.textTheme.titleMedium!
                      .copyWith(fontStyle: FontStyle.italic),
                )
              : Text(
                  member.name,
                  style: theme.textTheme.titleLarge!,
                )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedListOf<Member>(
      key: _listKey,
      itemBuilder: _itemBuilder,
    );
  }
}
