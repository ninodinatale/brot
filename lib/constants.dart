import 'package:logger/logger.dart';

final blog = Logger(
    printer: PrettyPrinter(
        noBoxingByDefault: true,
        errorMethodCount: 30,
        methodCount: 0,
        lineLength: 80));

const PENDING_GAME_PREFS_KEY = 'pendingGameKey';

enum ErrorCodes { gameNotFound, gameAlreadyStarted, gameHasWrongStatus }
