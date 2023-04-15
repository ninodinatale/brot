import 'dart:io' as io;

import 'package:logger/logger.dart';

/// Don't use [blog] directly when possible, use functions [logI] etc.
final blog = Logger(printer: BrotLogPrinter());

class BrotLogPrinter extends PrettyPrinter {
  BrotLogPrinter()
      : super(
            noBoxingByDefault: true,
            errorMethodCount: 30,
            methodCount: 0,
            colors: true,
            lineLength: io.stdout.hasTerminal ? io.stdout.terminalColumns : 80);
}

/// Logs message of log level [Level.info]. Replaces all occurrences of {``}
/// with the corresponding object in [interpolations].
void logI(String message, [List<String>? interpolations]) {
  if (interpolations == null) {
    blog.i(message);
    return;
  }

  var index = 0;
  String formattedMessage = message.replaceAllMapped(
    RegExp(r'\{\}'),
    (match) {
      // blue background with low opacity.
      return '\u001b[48;2;0;0;100;64m${interpolations[index++]}\u001b[49m';
    },
  );
  blog.i(formattedMessage);
}
