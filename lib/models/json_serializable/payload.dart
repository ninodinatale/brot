import 'package:json_annotation/json_annotation.dart';

part 'payload.g.dart';

@JsonSerializable()
class Payload {
  final String userId;

  Payload({required this.userId});

  Map<String, dynamic> toJson() => _$PayloadToJson(this);
}

@JsonSerializable(createFactory: false)
class DataPayload<T extends ToJsonSerializable> extends Payload {
  @_GenericConverter()
  final T data;

  DataPayload({required this.data, required super.userId});

  @override
  Map<String, dynamic> toJson() => _$DataPayloadToJson(this);
}

abstract class ToJsonSerializable extends Object {
  Map<String, dynamic> toJson();
}

@JsonSerializable(createFactory: false)
class JoinGamePayload implements ToJsonSerializable {
  String gameId;

  JoinGamePayload({required this.gameId});

  @override
  Map<String, dynamic> toJson() => _$JoinGamePayloadToJson(this);
}

class _GenericConverter<T extends ToJsonSerializable>
    implements JsonConverter<T, Object> {
  const _GenericConverter();

  @override
  T fromJson(Object json) {
    throw UnimplementedError('fromJson is not implemented.');
  }

  @override
  Map<String, dynamic> toJson(T object) {
    return object.toJson();
  }
}
