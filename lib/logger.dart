import 'dart:io' as io;

import 'package:logger/logger.dart';

class BrotLogPrinter extends PrettyPrinter {
  BrotLogPrinter()
      : super(
    stackTraceBeginIndex: 2,
            noBoxingByDefault: false,
            errorMethodCount: 30,
            methodCount: 3,
            colors: io.stdout.supportsAnsiEscapes,
            lineLength: io.stdout.hasTerminal ? io.stdout.terminalColumns : 80);
}

final _printer = BrotLogPrinter();

final _blog = Logger(printer: _printer);

/// Logs message of log level [Level.info]. Replaces all occurrences of {``}
/// with the corresponding object in [interpolations].
void logI(String message, [List<String>? interpolations]) {
  _log(Level.info, message, interpolations);
}

/// Logs message of log level [Level.error]. Replaces all occurrences of {``}
/// with the corresponding object in [interpolations].
void logE(String message, [List<String>? interpolations]) {
  _log(Level.error, message, interpolations);
}

/// Logs message of log level [Level.warning]. Replaces all occurrences of {``}
/// with the corresponding object in [interpolations].
void logW(String message, [List<String>? interpolations]) {
  _log(Level.warning, message, interpolations);
}

void _log(Level level, String message, List<String>? interpolations) {
  String finalMessage = message;
  String escapePrefix = '';
  String escapeSuffix = '';

  if (_printer.colors) {
    String r = '0';
    String g = '0';
    String b = '0';

    switch (level) {
      case Level.verbose:
        // do nothing.
        break;
      case Level.debug:
        // do nothing.
        break;
      case Level.info:
        b = '100';
        break;
      case Level.warning:
        g = '50';
        r = '50';
        break;
      case Level.error:
        r = '60';
        break;
      case Level.wtf:
        // do nothing.
        break;
      case Level.nothing:
        // do nothing.
        break;
    }

    escapePrefix = '\u001b[48;2;$r;$g;$b;64m';
    escapeSuffix = '\u001b[49m';
  }

  if (interpolations != null) {
    var index = 0;
    finalMessage = message.replaceAllMapped(
      RegExp(r'\{\}'),
      (match) {
        // blue background with low opacity.
        return '\n$escapePrefix${interpolations[index++]}$escapeSuffix\n';
      },
    );
  }

  _blog.log(level, finalMessage, null, StackTrace.current);
}
