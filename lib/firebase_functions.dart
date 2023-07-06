import 'package:brot/models/payload/payloads.dart';
import 'package:cloud_functions/cloud_functions.dart';

class BrotFirebaseFunctions {
  static final _fbFunctionInstance =
      FirebaseFunctions.instanceFor(region: 'europe-west1');
  static final _options =
      HttpsCallableOptions(timeout: const Duration(seconds: 10));

  static Future<CreateGameResponse> callCreateGame(
      CreateGamePayload payload) {
    return _fbFunctionInstance
        .httpsCallable('createGame', options: _options)
        .call(payload.toJson())
        .then((response) => CreateGameResponse.fromJson(response.data));
  }

  static Future<GetGameResponse> callGetGame(
      GetGamePayload payload) {
    return _fbFunctionInstance
        .httpsCallable('getGame', options: _options)
        .call(payload.toJson())
        .then((response) => GetGameResponse.fromJson(response.data));
  }

  static Future<GetMemberResponse> callGetMember(
      GetMemberPayload payload) {
    return _fbFunctionInstance
        .httpsCallable('getMember', options: _options)
        .call(payload.toJson())
        .then((response) => GetMemberResponse.fromJson(response.data))
    .catchError((e) => e);
  }

  static Future<void> callStartGame(
      StartGamePayload payload) {
    return _fbFunctionInstance
        .httpsCallable('startGame', options: _options)
        .call(payload.toJson())
        .then((response) => null);
  }

  static Future<void> callVoteForWord(
      VoteWordPayload payload) {
    return _fbFunctionInstance
        .httpsCallable('voteWord', options: _options)
        .call(payload.toJson())
        .then((response) => null);
  }

  static useEmulator(String host, int port) {
    _fbFunctionInstance.useFunctionsEmulator(host, port);
  }
}
