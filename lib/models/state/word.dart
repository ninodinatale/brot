import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'word.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
@immutable
class Word {
  final String userId;
  final String value;
  final int votes = 0;

  const Word({required this.value, required this.userId});

  factory Word.firstFromJson(Map<dynamic, dynamic> json) =>
      Word.fromJson(json.values.first);

  factory Word.fromJson(Map<dynamic, dynamic> json) => _$WordFromJson(json);

  Map<String, dynamic> toJson() => _$WordToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

typedef AddedWord = Word;
typedef UserHasWord = bool;