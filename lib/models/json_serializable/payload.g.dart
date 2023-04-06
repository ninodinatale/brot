// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payload _$PayloadFromJson(Map<String, dynamic> json) => Payload(
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$PayloadToJson(Payload instance) => <String, dynamic>{
      'userId': instance.userId,
    };

Map<String, dynamic> _$DataPayloadToJson<T extends ToJsonSerializable>(
        DataPayload<T> instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'data': _GenericConverter<T>().toJson(instance.data),
    };

Map<String, dynamic> _$JoinGamePayloadToJson(JoinGamePayload instance) =>
    <String, dynamic>{
      'gameId': instance.gameId,
    };
