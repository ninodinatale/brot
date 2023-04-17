import 'dart:async';

import 'package:brot/models/state/member.dart';
import 'package:brot/widgets/brot_animated_list.dart';
import 'package:brot/widgets/dot3_progress_indicator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../../logger.dart';

class ContentMembersWidget extends StatefulWidget {
  const ContentMembersWidget(this.gameKey, {Key? key}) : super(key: key);

  final String gameKey;

  @override
  State<ContentMembersWidget> createState() => _ContentMembersWidgetState();
}

class _ContentMembersWidgetState extends State<ContentMembersWidget> {
  final _list = GlobalKey<AnimatedListStateOf<Member>>();
  late List<StreamSubscription> _subs;

  @override
  void initState() {
    super.initState();
    _subs = [
      FirebaseDatabase.instance
          .ref('/members/${widget.gameKey}')
          .onChildAdded
          .listen((event) {
        logI('onChildAdded fired for path {} with value {}',
            ['/members/${widget.gameKey}', '${event.snapshot.value}']);
        _list.currentState
            ?.insert(Member.fromJson(event.snapshot.value as Map));
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
          .listen((event) {
        logI('onChildChanged fired for path {} with value {}',
            ['/members/${widget.gameKey}', '${event.snapshot.value}']);
        final changedMember = Member.fromJson(event.snapshot.value as Map);
        final index = _list.currentState?.items.indexWhere(
            (existingMember) => existingMember.key == changedMember.key);
        if (index != null && index >= 0) {
          setState(() {
            _list.currentState?.items
                .replaceRange(index, index + 1, [changedMember]);
          });
        } else {
          logE(
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

  Widget _itemBuilder(BuildContext context, Member member, bool isSelected) {
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
      key: _list,
      itemBuilder: _itemBuilder,
    );
  }
}
