import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'game.g.dart';

enum GameStatus {
  @JsonValue(0)
  lobby,
  @JsonValue(1)
  scoreBoard,
  @JsonValue(2)
  choosingBread,
  @JsonValue(3)
  votingWords,
  @JsonValue(4)
  playing;
}

@JsonSerializable(explicitToJson: true, anyMap: true)
class Game extends ChangeNotifier {
  final String key;
  final String gameCode;
  final String adminUserId;
  final GameStatus status;

  Game(
      {required this.key,
      required this.gameCode,
      required this.adminUserId,
      required this.status});

  factory Game.firstFromJson(Map<dynamic, dynamic> json) =>
      Game.fromJson(json.values.first);

  factory Game.fromJson(Map<dynamic, dynamic> json) => _$GameFromJson(json);

  Map<String, dynamic> toJson() => _$GameToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
