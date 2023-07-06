// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payloads.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JoinGamePayload _$JoinGamePayloadFromJson(Map<String, dynamic> json) =>
    JoinGamePayload(
      userId: json['userId'] as String,
      gameCode: json['gameCode'] as String,
    );

Map<String, dynamic> _$JoinGamePayloadToJson(JoinGamePayload instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'gameCode': instance.gameCode,
    };

ChooseBreadPayload _$ChooseBreadPayloadFromJson(Map<String, dynamic> json) =>
    ChooseBreadPayload(
      userId: json['userId'] as String,
      gameKey: json['gameKey'] as String,
    );

Map<String, dynamic> _$ChooseBreadPayloadToJson(ChooseBreadPayload instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'gameKey': instance.gameKey,
    };

VoteWordPayload _$VoteWordPayloadFromJson(Map<String, dynamic> json) =>
    VoteWordPayload(
      userId: json['userId'] as String,
      gameKey: json['gameKey'] as String,
      wordKey: json['wordKey'] as String,
    );

Map<String, dynamic> _$VoteWordPayloadToJson(VoteWordPayload instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'gameKey': instance.gameKey,
      'wordKey': instance.wordKey,
    };

GetGamePayload _$GetGamePayloadFromJson(Map<String, dynamic> json) =>
    GetGamePayload(
      gameKey: json['gameKey'] as String,
    );

Map<String, dynamic> _$GetGamePayloadToJson(GetGamePayload instance) =>
    <String, dynamic>{
      'gameKey': instance.gameKey,
    };

CreateGamePayload _$CreateGamePayloadFromJson(Map<String, dynamic> json) =>
    CreateGamePayload(
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$CreateGamePayloadToJson(CreateGamePayload instance) =>
    <String, dynamic>{
      'userId': instance.userId,
    };

StartGamePayload _$StartGamePayloadFromJson(Map<String, dynamic> json) =>
    StartGamePayload(
      gameKey: json['gameKey'] as String,
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$StartGamePayloadToJson(StartGamePayload instance) =>
    <String, dynamic>{
      'gameKey': instance.gameKey,
      'userId': instance.userId,
    };

GetMemberPayload _$GetMemberPayloadFromJson(Map<String, dynamic> json) =>
    GetMemberPayload(
      gameKey: json['gameKey'] as String,
      memberKey: json['memberKey'] as String,
    );

Map<String, dynamic> _$GetMemberPayloadToJson(GetMemberPayload instance) =>
    <String, dynamic>{
      'gameKey': instance.gameKey,
      'memberKey': instance.memberKey,
    };

CreateGameResponse _$CreateGameResponseFromJson(Map<String, dynamic> json) =>
    CreateGameResponse(
      gameKey: json['gameKey'] as String,
      memberKey: json['memberKey'] as String,
    );

Map<String, dynamic> _$CreateGameResponseToJson(CreateGameResponse instance) =>
    <String, dynamic>{
      'gameKey': instance.gameKey,
      'memberKey': instance.memberKey,
    };

GetGameResponse _$GetGameResponseFromJson(Map<String, dynamic> json) =>
    GetGameResponse(
      key: json['key'] as String,
      gameCode: json['gameCode'] as String,
      adminUserId: json['adminUserId'] as String,
      status: $enumDecode(_$GameStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$GetGameResponseToJson(GetGameResponse instance) =>
    <String, dynamic>{
      'key': instance.key,
      'gameCode': instance.gameCode,
      'adminUserId': instance.adminUserId,
      'status': _$GameStatusEnumMap[instance.status]!,
    };

const _$GameStatusEnumMap = {
  GameStatus.lobby: 0,
  GameStatus.scoreBoard: 1,
  GameStatus.choosingBread: 2,
  GameStatus.votingWords: 3,
  GameStatus.playing: 4,
};

GetMemberResponse _$GetMemberResponseFromJson(Map<String, dynamic> json) =>
    GetMemberResponse(
      key: json['key'] as String,
      userId: json['userId'] as String,
      isAdmin: json['isAdmin'] as bool,
      points: json['points'] as int,
      hasVotedForWord: json['hasVotedForWord'] as bool,
      name: json['name'] as String,
      isBread: json['isBread'] as bool,
    );

Map<String, dynamic> _$GetMemberResponseToJson(GetMemberResponse instance) =>
    <String, dynamic>{
      'key': instance.key,
      'userId': instance.userId,
      'name': instance.name,
      'isAdmin': instance.isAdmin,
      'isBread': instance.isBread,
      'hasVotedForWord': instance.hasVotedForWord,
      'points': instance.points,
    };
