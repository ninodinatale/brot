import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'word.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
@immutable
class Word {
  final String key;
  final String userId;
  final String gameKey;
  final String value;
  final int votes;

  const Word({required this.key, required this.value, required this.gameKey, required this.userId, this.votes = 0});

  factory Word.firstFromJson(Map<dynamic, dynamic> json) =>
      Word.fromJson(json.values.first);

  factory Word.fromJson(Map<dynamic, dynamic> json) => _$WordFromJson(json);

  Map<String, dynamic> toJson() => _$WordToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

@JsonSerializable()
@immutable
class UserHasWord {
  final bool value;

  const UserHasWord(this.value);

  factory UserHasWord.fromJson(Map<String, dynamic> json) => _$UserHasWordFromJson(json);
}