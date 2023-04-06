import 'package:brot/models/json_serializable/game_model.dart';
import 'package:flutter/cupertino.dart';

class MembersState extends ChangeNotifier {
  Map<String, MemberModel> members = {};

  updateMembers(MembersModel membersModel) {
    members = membersModel.members;
    notifyListeners();
  }
}
