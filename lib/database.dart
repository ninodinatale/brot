import 'dart:math';

import 'package:brot/constants.dart';
import 'package:brot/models/state/game.dart';
import 'package:brot/models/state/member.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

///
/// Creates a game and joins it.
///
/// Returns the key of the created game.
///
Future<Tuple2<String, String>> createGame(String userId) async {
  blog.i('creating game for user $userId');

  var gameCode = '';
  while (gameCode == '') {
    // enough unique lol, finished games are going to be deleted anyway.
    final potentialGameCode = (100000 + Random().nextInt(899999)).toString();

    final snap = (await FirebaseDatabase.instance
            .ref()
            .child('games')
            .orderByChild('gameCode')
            .equalTo(potentialGameCode)
            .once())
        .snapshot;

    if (!snap.exists) {
      gameCode = potentialGameCode;
    }
  }

  blog.i('game code will be $gameCode');

  final newGameRef = FirebaseDatabase.instance.ref('/games').push();
  final newGame = Game(
      key: newGameRef.key!,
      gameCode: gameCode,
      adminUserId: userId,
      status: GameStatus.lobby);

  late String memberKey;

  await newGameRef.set(newGame.toJson()).then((value) {
    blog.i('game $newGame created');
  }).then((value) async {
    memberKey = (await _createMember(
            gameKey: newGameRef.key!, userId: userId, isAdmin: true))
        .key;
  }).catchError((error, stackTrace) {
    blog.e('error creating game', stackTrace);
  });

  return Tuple2(newGame.key, memberKey);
}

///
/// Joins the game with the given [gameCode] and creates a member entry
/// if none exists for the user with the [userId].
///
/// Returns the key of the joined game or an error if the game
/// does not exist.
///
Future<Tuple2<String, String>> joinGame(String userId, String gameCode) async {
  blog.i('try joining game with code $gameCode for user $userId');

  final gameQuery = FirebaseDatabase.instance
      .ref()
      .child('games')
      .orderByChild('gameCode')
      .equalTo(gameCode);

  final gameSnap = (await gameQuery.once()).snapshot;

  if (!gameSnap.exists) {
    blog.i('game with code $gameCode does not exist, returning error');
    return Future.error({'code': ErrorCodes.gameNotFound});
  }

  final game = Game.firstFromJson(gameSnap.value as Map);

  if (game.status != GameStatus.lobby) {
    blog.i('game $game has already started, cannot join');
    return Future.error({'code': ErrorCodes.gameAlreadyStarted});
  }

  final String gameKey = game.key;
  final gameMembersRef =
      FirebaseDatabase.instance.ref().child('/members/$gameKey');
  final existingMemberSnap =
      (await gameMembersRef.orderByChild('userId').equalTo(userId).once())
          .snapshot;

  late String memberKey;
  if (!existingMemberSnap.exists) {
    memberKey =
        (await _createMember(gameKey: gameKey, userId: userId, isAdmin: false))
            .key;
  } else {
    memberKey =
        Member.fromJson((existingMemberSnap.value as Map).values.first).key;
    blog.i('user already exists as member; nothing to do');
  }

  return Tuple2(gameKey, memberKey);
}

///
/// Chooses a bread randomly from the members of the game with [gameKey] key.
///
Future<void> chooseBread(String gameKey) async {
  blog.i('choosing bread for game with key $gameKey');

  final gameSnap =
      await FirebaseDatabase.instance.ref().child('/games/$gameKey').get();

  if (!gameSnap.exists) {
    blog.e('game with key $gameKey not found');
    return Future.error({'code': ErrorCodes.gameNotFound});
  }

  final game = Game.fromJson(gameSnap.value as Map);

  if (game.status != GameStatus.choosingBread) {
    blog.e('game $game has wrong status, cannot choose bread');
    return Future.error({'code': ErrorCodes.gameHasWrongStatus});
  }

  final gameMembersSnap =
      await FirebaseDatabase.instance.ref().child('/members/$gameKey').get();

  if (!gameMembersSnap.exists) {
    blog.e('members for game $gameSnap do not exist');
    return;
  }

  final allMembers = gameMembersSnap.children
      .map((membersSnap) => Member.fromJson(membersSnap.value as Map))
      .toList();
  blog.i('selecting from ${allMembers.length} members a bread randomly');

  final randomIndex = Random().nextInt(allMembers.length);
  final breadMember = allMembers[randomIndex];

  blog.i('random index is $randomIndex');

  await FirebaseDatabase.instance
      .ref()
      .child('/members/$gameKey/${breadMember.key}/isBread')
      .set(true);

  blog.i('member $breadMember will be the bread');
}

///
/// Creates a member with the passed [gameMemberRef] and returns the created
/// member as a [Member] instance.
///
/// As a side effect, stores the game key locally to know if the user is
/// currently in a game without querying the db.
///
Future<Member> _createMember(
    {required String userId,
    required String gameKey,
    required bool isAdmin}) async {
  blog.i('creating member');
  final newMemberRef =
      FirebaseDatabase.instance.ref('/members/$gameKey').push();

  final newMember = Member(
      key: newMemberRef.key!, userId: userId, isAdmin: isAdmin, name: '');
  await newMemberRef.set(newMember.toJson());
  blog.i('member $newMember created');

  SharedPreferences.getInstance()
      .then((prefs) => prefs.setString(PENDING_GAME_PREFS_KEY, gameKey));

  return newMember;
}
