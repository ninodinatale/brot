import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

import '../state/game.dart';

part 'payloads.g.dart';

@JsonSerializable()
class JoinGamePayload {
  String userId;
  String gameCode;

  JoinGamePayload({required this.userId, required this.gameCode});

  Map<String, dynamic> toJson() => _$JoinGamePayloadToJson(this);
}

@JsonSerializable()
class ChooseBreadPayload {
  String userId;
  String gameKey;

  ChooseBreadPayload({required this.userId, required this.gameKey});

  Map<String, dynamic> toJson() => _$ChooseBreadPayloadToJson(this);
}

@JsonSerializable()
class VoteWordPayload {
  String userId;
  String gameKey;
  String wordKey;

  VoteWordPayload(
      {required this.userId, required this.gameKey, required this.wordKey});

  Map<String, dynamic> toJson() => _$VoteWordPayloadToJson(this);
}

@JsonSerializable()
class GetGamePayload {
  String gameKey;

  GetGamePayload({required this.gameKey});

  Map<String, dynamic> toJson() => _$GetGamePayloadToJson(this);
}

@JsonSerializable()
class CreateGamePayload {
  String userId;

  CreateGamePayload({required this.userId});

  Map<String, dynamic> toJson() => _$CreateGamePayloadToJson(this);
}

@JsonSerializable()
class StartGamePayload {
  String gameKey;
  String userId;

  StartGamePayload({required this.gameKey, required this.userId});

  Map<String, dynamic> toJson() => _$StartGamePayloadToJson(this);
}

@JsonSerializable()
class GetMemberPayload {
  String gameKey;
  String memberKey;

  GetMemberPayload({required this.gameKey, required this.memberKey});

  Map<String, dynamic> toJson() => _$GetMemberPayloadToJson(this);
}

@immutable
@JsonSerializable()
class CreateGameResponse {
  final String gameKey;
  final String memberKey;

  const CreateGameResponse({required this.gameKey, required this.memberKey});

  factory CreateGameResponse.fromJson(Map<String, dynamic> json) => _$CreateGameResponseFromJson(json);

}

@immutable
@JsonSerializable()
class GetGameResponse {
  final String key;
  final String gameCode;
  final String adminUserId;
  final GameStatus status;

  const GetGameResponse(
      {required this.key,
      required this.gameCode,
      required this.adminUserId,
      required this.status});

  factory GetGameResponse.fromJson(Map<String, dynamic> json) => _$GetGameResponseFromJson(json);
}

@immutable
@JsonSerializable()
class GetMemberResponse {
  final String key;
  final String userId;
  final String name;
  final bool isAdmin;
  final bool isBread;
  final bool hasVotedForWord;
  final int points;

  const GetMemberResponse(
      {required this.key,
      required this.userId,
      required this.isAdmin,
      required this.points,
      required this.hasVotedForWord,
      required this.name,
      required this.isBread});

  factory GetMemberResponse.fromJson(Map<String, dynamic> json) => _$GetMemberResponseFromJson(json);

}
