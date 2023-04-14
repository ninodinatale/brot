// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Game _$GameFromJson(Map json) => Game(
      key: json['key'] as String,
      gameCode: json['gameCode'] as String,
      adminUserId: json['adminUserId'] as String,
      status: $enumDecode(_$GameStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
      'key': instance.key,
      'gameCode': instance.gameCode,
      'adminUserId': instance.adminUserId,
      'status': _$GameStatusEnumMap[instance.status]!,
    };

const _$GameStatusEnumMap = {
  GameStatus.lobby: 0,
  GameStatus.choosingBread: 1,
  GameStatus.votingWords: 2,
  GameStatus.playing: 3,
};
