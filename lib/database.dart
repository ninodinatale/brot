// import 'dart:math';
//
// import 'package:brot/constants.dart';
// import 'package:brot/models/state/game.dart';
// import 'package:brot/models/state/member.dart';
// import 'package:brot/models/state/word.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tuple/tuple.dart';
//
// import 'logger.dart';
// import 'models/state/user_id.dart';
//
// ///
// /// Creates a game and joins it.
// ///
// /// Returns the key of the created game.
// ///
// Future<Tuple2<String, String>> createGame(String userId) async {
//   logI('creating game for user {}', [userId]);
//
//   var gameCode = '';
//   while (gameCode == '') {
//     // enough unique lol, finished games are going to be deleted anyway.
//     final potentialGameCode = (100000 + Random().nextInt(899999)).toString();
//
//     final snap = (await FirebaseDatabase.instance
//             .ref()
//             .child('games')
//             .orderByChild('gameCode')
//             .equalTo(potentialGameCode)
//             .once())
//         .snapshot;
//
//     if (!snap.exists) {
//       gameCode = potentialGameCode;
//     }
//   }
//
//   logI('game code will be {}', [gameCode]);
//
//   final newGameRef = FirebaseDatabase.instance.ref('/games').push();
//   final newGame = Game(
//       key: newGameRef.key!,
//       gameCode: gameCode,
//       adminUserId: userId,
//       status: GameStatus.lobby);
//
//   late String memberKey;
//
//   await newGameRef.set(newGame.toJson()).then((value) {
//     logI('game {} created', ['$newGame']);
//   }).then((value) async {
//     memberKey = (await _createMember(
//             gameKey: newGameRef.key!, userId: userId, isAdmin: true))
//         .key;
//   }).catchError((error, stackTrace) {
//     logE('error creating game', stackTrace);
//   });
//
//   return Tuple2(newGame.key, memberKey);
// }
//
// ///
// /// Joins the game with the given [gameCode] and creates a member entry
// /// if none exists for the user with the [userId].
// ///
// /// Returns the key of the joined game or an error if the game
// /// does not exist.
// ///
// Future<Tuple2<String, String>> joinGame(String userId, String gameCode) async {
//   logI('try joining game with code {} for user with id {}', [gameCode, userId]);
//
//   final gameQuery = FirebaseDatabase.instance
//       .ref()
//       .child('games')
//       .orderByChild('gameCode')
//       .equalTo(gameCode);
//
//   final gameSnap = (await gameQuery.once()).snapshot;
//
//   if (!gameSnap.exists) {
//     logI('game with code {} does not exist, returning error', [gameCode]);
//     return Future.error({'code': ErrorCodes.gameNotFound});
//   }
//
//   final game = Game.firstFromJson(gameSnap.value as Map);
//
//   if (game.status != GameStatus.lobby) {
//     logI('game {} has already started, cannot join', ['$game']);
//     return Future.error({'code': ErrorCodes.gameAlreadyStarted});
//   }
//
//   final String gameKey = game.key;
//   final gameMembersRef =
//       FirebaseDatabase.instance.ref().child('/members/$gameKey');
//   final existingMemberSnap =
//       (await gameMembersRef.orderByChild('userId').equalTo(userId).once())
//           .snapshot;
//
//   late String memberKey;
//   if (!existingMemberSnap.exists) {
//     memberKey =
//         (await _createMember(gameKey: gameKey, userId: userId, isAdmin: false))
//             .key;
//   } else {
//     memberKey =
//         Member.fromJson((existingMemberSnap.value as Map).values.first).key;
//     logI('user already exists as member; nothing to do');
//   }
//
//   return Tuple2(gameKey, memberKey);
// }
//
// ///
// /// Chooses a bread randomly from the members of the game with [gameKey] key.
// ///
// Future<void> chooseBread(String gameKey) async {
//   logI('choosing bread for game with key {}', [gameKey]);
//
//   final gameSnap =
//       await FirebaseDatabase.instance.ref().child('/games/$gameKey').get();
//
//   if (!gameSnap.exists) {
//     logE('game with key $gameKey not found');
//     return Future.error({'code': ErrorCodes.gameNotFound});
//   }
//
//   final game = Game.fromJson(gameSnap.value as Map);
//
//   if (game.status != GameStatus.choosingBread) {
//     logE('game $game has wrong status, cannot choose bread');
//     return Future.error({'code': ErrorCodes.gameHasWrongStatus});
//   }
//
//   final gameMembersSnap =
//       await FirebaseDatabase.instance.ref().child('/members/$gameKey').get();
//
//   if (!gameMembersSnap.exists) {
//     logE('members for game $gameSnap do not exist');
//     return;
//   }
//
//   final allMembers = gameMembersSnap.children
//       .map((membersSnap) => Member.fromJson(membersSnap.value as Map))
//       .toList();
//   logI('selecting from {} members a bread randomly', ['${allMembers.length}']);
//
//   final randomIndex = Random().nextInt(allMembers.length);
//   final breadMember = allMembers[2];
//
//   logI('random index is {}', ['$randomIndex']);
//
//   await FirebaseDatabase.instance
//       .ref()
//       .child('/members/$gameKey/${breadMember.key}/isBread')
//       .set(true);
//
//   logI('member {} will be the bread', ['$breadMember']);
// }
//
// ///
// /// Vote for word
// ///
// Future<void> voteForWord(Word word, UserId userId) async {
//   logI('userId {} voting for word {}', [userId, '$word']);
//
//   await getGame(word.gameKey).then((game) {
//     if (game.status != GameStatus.votingWords) {
//       logE('game {} has wrong status, cannot vote', ['$game']);
//       return Future.error({'code': ErrorCodes.gameHasWrongStatus});
//     }
//   });
//
//   final userMemberSnap = await FirebaseDatabase.instance
//       .ref('/members/${word.gameKey}')
//       .orderByChild('userId')
//       .equalTo(userId)
//       .get();
//
//   final userMember = Member.firstFromJson(userMemberSnap.value as Map);
//
//   if (userMemberSnap.exists && userMember.hasVotedForWord) {
//     logE('user {} already voted for word {}', [userId, '$word']);
//     return Future.error({'code': ErrorCodes.alreadyVotedWord});
//   }
//
//   final result = await FirebaseDatabase.instance
//       .ref('/words/${word.gameKey}/${word.key}')
//       .runTransaction((Object? dbWord) {
//     if (dbWord == null) {
//       logE('word {} not found', ['$word']);
//       return Transaction.abort();
//     }
//
//     final _word = Word.fromJson(dbWord as Map);
//
//     final _updated = Word(
//         userId: _word.userId,
//         value: _word.value,
//         key: _word.key,
//         gameKey: _word.gameKey,
//         votes: _word.votes + 1);
//
//     FirebaseDatabase.instance
//         .ref('/members/${word.gameKey}/${userMember.key}/hasVotedForWord')
//         .set(true);
//     return Transaction.success(_updated.toJson());
//   });
//
//   if (!result.committed) {
//     return Future.error({'code': ErrorCodes.wordNotFound});
//   }
// }
//
// ///
// /// Creates a member with the passed [gameMemberRef] and returns the created
// /// member as a [Member] instance.
// ///
// /// As a side effect, stores the game key locally to know if the user is
// /// currently in a game without querying the db.
// ///
// Future<Member> _createMember(
//     {required String userId,
//     required String gameKey,
//     required bool isAdmin}) async {
//   logI('creating member');
//   final newMemberRef =
//       FirebaseDatabase.instance.ref('/members/$gameKey').push();
//
//   final newMember = Member(
//       key: newMemberRef.key!, userId: userId, isAdmin: isAdmin, name: '');
//   await newMemberRef.set(newMember.toJson());
//   logI('member {} created', ['$newMember']);
//
//   SharedPreferences.getInstance()
//       .then((prefs) => prefs.setString(PENDING_GAME_PREFS_KEY, gameKey));
//
//   return newMember;
// }
//
// import 'package:firebase_database/firebase_database.dart';
//
// import 'models/state/game.dart';
//
// Future<Game> getGame(String gameKey) async {
//   final gameSnap =
//       await FirebaseDatabase.instance.ref().child('/games/$gameKey').get();
//
//   if (!gameSnap.exists) {
//     logE('game with key {} not found', [gameKey]);
//     return Future.error({'code': ErrorCodes.gameNotFound});
//   }
//
//   final game = Game.fromJson(gameSnap.value as Map);
//   return game;
// }
//
// Future<Member> getMember(String gameKey, String memberKey) async {
//   final memberSnapshot = await FirebaseDatabase.instance
//       .ref('/members/${gameKey}/${memberKey}')
//       .get();
//
//   if (!memberSnapshot.exists) {
//     logE('member with key {} from game with key {} not found',
//         [memberKey, gameKey]);
//     return Future.error({'code': ErrorCodes.gameNotFound});
//   }
//
//   final member = Member.fromJson(memberSnapshot.value as Map);
//   return member;
// }
