import 'package:brot/models/json_serializable/game_model.dart';
import 'package:flutter/cupertino.dart';


class GameState extends ChangeNotifier {
  final int id;
  final String userId;
  final String adminUserId;
  final GameStatus status;

  GameState({required this.id, required this.userId, required this.adminUserId, required this.status});

  factory GameState.fromGameModel(GameModel model) {
    return GameState(id: model.gameId, userId: model.userId, adminUserId: model.adminUserId, status: model.status);
  }
}