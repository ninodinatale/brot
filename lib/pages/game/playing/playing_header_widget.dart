import 'package:brot/models/state/game.dart';
import 'package:brot/models/state/user_id.dart';
import 'package:brot/models/state/user_member.dart';
import 'package:brot/pages/game/playing/is_bread_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'not_bread_header_widget.dart';

class VotingWordsHeaderWidget extends StatelessWidget {
  const VotingWordsHeaderWidget({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final gameKey = Provider.of<Game>(context).key;
    final userId = Provider.of<UserId>(context);
    final userMember = Provider.of<UserMember>(context);
    return userMember.isBread ? const IsBreadHeaderWidget() : NotBreadHeaderWidget(gameKey: gameKey, userId: userId);
  }
}
