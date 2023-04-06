import 'package:brot/models/json_serializable/game_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/state/MembersState.dart';

class MembersWidget extends StatefulWidget {
  const MembersWidget({Key? key}) : super(key: key);

  @override
  State<MembersWidget> createState() => _MembersWidgetState();
}

class _MembersWidgetState extends State<MembersWidget> {
  @override
  Widget build(BuildContext context) {
    final membersState = Provider.of<MembersState>(context);

    Map<String, MemberModel> membersWithName = {};
    for (var element in membersState.members.entries) {
      if (element.value.name != '_UNSET_') {
        membersWithName.putIfAbsent(element.key, () => MemberModel(name: element.value.name, isAdmin: element.value.isAdmin,));
      }
    }

    return ListView.builder(
      itemCount: membersWithName.length,
      itemBuilder: (context, index) {
        String key = membersWithName.keys.elementAt(index);
        return Card(
          child: ListTile(title: Text(membersWithName[key]!.name)),
        );
      },
    );
  }
}
