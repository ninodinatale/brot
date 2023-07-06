import 'dart:async';

import 'package:brot/models/state/member.dart';
import 'package:brot/widgets/animated_count.dart';
import 'package:brot/widgets/brot_animated_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../logger.dart';
import '../../../models/state/user_id.dart';
import '../../../widgets/brot_list_item.dart';

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
          .onValue
          .map((event) {
            logI('onChildAdded fired for path {} with value {}',
                ['/members/${widget.gameKey}', '${event.snapshot.value}']);
            return Member.fromJson(event.snapshot.value as Map);
          })
          .where((member) => member.name.isNotEmpty)
          .listen((member) {
            _list.currentState?.insert(member);
          }),
    ];
  }

  @override
  void dispose() {
    super.dispose();
    _subs.forEach((sub) => sub.cancel());
  }

  Widget _itemBuilder(BuildContext context, Member member, bool isSelected) {
    final theme = Theme.of(context);
    final userId = Provider.of<UserId>(context);
    final iconColor = member.userId == userId
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary;
    return BrotListItem(
      leading: Icon(Icons.account_circle, color: iconColor, size: 28),
      title: Text(
        member.name,
      ),
      subtitle: const Text('War noch nicht Brot'),
      trailing: AnimatedCount(count: member.points),
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
