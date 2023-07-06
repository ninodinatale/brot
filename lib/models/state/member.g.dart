// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Member _$MemberFromJson(Map json) => Member(
      key: json['key'] as String,
      userId: json['userId'] as String,
      isAdmin: json['isAdmin'] as bool,
      points: json['points'] as int,
      hasVotedForWord: json['hasVotedForWord'] as bool,
      name: json['name'] as String,
      isBread: json['isBread'] as bool,
    );

Map<String, dynamic> _$MemberToJson(Member instance) => <String, dynamic>{
      'key': instance.key,
      'userId': instance.userId,
      'name': instance.name,
      'isAdmin': instance.isAdmin,
      'isBread': instance.isBread,
      'hasVotedForWord': instance.hasVotedForWord,
      'points': instance.points,
    };

UserIsBread _$UserIsBreadFromJson(Map json) => UserIsBread(
      json['value'] as bool,
    );

Map<String, dynamic> _$UserIsBreadToJson(UserIsBread instance) =>
    <String, dynamic>{
      'value': instance.value,
    };
