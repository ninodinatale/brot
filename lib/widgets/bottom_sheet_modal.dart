import 'package:flutter/material.dart';

Future<T?> brotModalBottomSheet<T>(
    {required BuildContext context, required Widget child}) {
  return showModalBottomSheet<T>(
      backgroundColor: Colors.transparent,
      isDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: child,
        );
      });
}
