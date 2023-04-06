import 'package:brot/pages/game/game_code_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/state/MembersState.dart';
import 'enter_name_widget.dart';


class LobbyHeaderWidget extends StatelessWidget {
  const LobbyHeaderWidget({
    super.key,
    required String userId,
  }) : _userId = userId;

  final String _userId;

  @override
  Widget build(BuildContext context) {
    final membersModel = Provider.of<MembersState>(context);

    return Padding(
        padding: const EdgeInsets.fromLTRB(10, 40, 10, 20),
        child: membersModel.members[_userId]?.name == '_UNSET_'
            ? const EnterNameWidget()
            : const GameCodeWidget());
  }
}
