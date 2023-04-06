import 'package:json_annotation/json_annotation.dart';

part 'game_model.g.dart';

typedef MembersMap = Map<String, MemberModel>;

enum GameStatus {
  @JsonValue(0)
  lobby,
  @JsonValue(1)
  playing;
}

@JsonSerializable(explicitToJson: true, anyMap: true)
class GameModel {
  final int gameId;
  final String userId;
  final String adminUserId;
  final GameStatus status;
  final MembersMap members;

  GameModel({required this.userId, required this.gameId, required this.adminUserId, required this.status, required this.members});

  factory GameModel.fromJson(Map<String, dynamic> json) =>
      _$GameModelFromJson(json);

  Map<String, dynamic> toJson() => _$GameModelToJson(this);
}

@JsonSerializable(explicitToJson: true, anyMap: true)
class MembersModel {
  final MembersMap members;

  MembersModel({required this.members});

  factory MembersModel.fromJson(Map<String, dynamic> json) =>
      _$MembersModelFromJson(json);

  Map<String, dynamic> toJson() => _$MembersModelToJson(this);
}

@JsonSerializable()
class MemberModel {
  final String name;
  final bool isAdmin;

  MemberModel({ required this.isAdmin, required this.name});

  factory MemberModel.fromJson(Map<String, dynamic> json) =>
      _$MemberModelFromJson(json);

  Map<String, dynamic> toJson() => _$MemberModelToJson(this);
}
