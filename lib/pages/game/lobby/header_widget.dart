import 'package:brot/pages/game/lobby/game_code_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/state/user_member.dart';
import 'enter_name_widget.dart';

class LobbyHeaderWidget extends StatelessWidget {
  const LobbyHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserMember>(
      builder: (context, userMember, child) => Padding(
          padding: const EdgeInsets.fromLTRB(10, 40, 10, 20),
          child: userMember.name == ''
              ? const EnterNameWidget()
              : const GameCodeWidget()),
    );
  }
}
