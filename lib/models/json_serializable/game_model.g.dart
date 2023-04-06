// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameModel _$GameModelFromJson(Map json) => GameModel(
      userId: json['userId'] as String,
      gameId: json['gameId'] as int,
      adminUserId: json['adminUserId'] as String,
      status: $enumDecode(_$GameStatusEnumMap, json['status']),
      members: (json['members'] as Map).map(
        (k, e) => MapEntry(k as String,
            MemberModel.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
    );

Map<String, dynamic> _$GameModelToJson(GameModel instance) => <String, dynamic>{
      'gameId': instance.gameId,
      'userId': instance.userId,
      'adminUserId': instance.adminUserId,
      'status': _$GameStatusEnumMap[instance.status]!,
      'members': instance.members.map((k, e) => MapEntry(k, e.toJson())),
    };

const _$GameStatusEnumMap = {
  GameStatus.lobby: 0,
  GameStatus.playing: 1,
};

MembersModel _$MembersModelFromJson(Map json) => MembersModel(
      members: (json['members'] as Map).map(
        (k, e) => MapEntry(k as String,
            MemberModel.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
    );

Map<String, dynamic> _$MembersModelToJson(MembersModel instance) =>
    <String, dynamic>{
      'members': instance.members.map((k, e) => MapEntry(k, e.toJson())),
    };

MemberModel _$MemberModelFromJson(Map<String, dynamic> json) => MemberModel(
      isAdmin: json['isAdmin'] as bool,
      name: json['name'] as String,
    );

Map<String, dynamic> _$MemberModelToJson(MemberModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'isAdmin': instance.isAdmin,
    };
