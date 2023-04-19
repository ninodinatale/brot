// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Word _$WordFromJson(Map json) => Word(
      key: json['key'] as String,
      value: json['value'] as String,
      gameKey: json['gameKey'] as String,
      userId: json['userId'] as String,
      votes: json['votes'] as int? ?? 0,
    );

Map<String, dynamic> _$WordToJson(Word instance) => <String, dynamic>{
      'key': instance.key,
      'userId': instance.userId,
      'gameKey': instance.gameKey,
      'value': instance.value,
      'votes': instance.votes,
    };

UserHasWord _$UserHasWordFromJson(Map<String, dynamic> json) => UserHasWord(
      json['value'] as bool,
    );

Map<String, dynamic> _$UserHasWordToJson(UserHasWord instance) =>
    <String, dynamic>{
      'value': instance.value,
    };
