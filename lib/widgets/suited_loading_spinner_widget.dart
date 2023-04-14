import 'package:flutter/material.dart';

class SuitedLoadingSpinner extends StatelessWidget {
  const SuitedLoadingSpinner({
    super.key,
    required this.color,
    this.size,
  });

  final Color color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            double finalSize = size != null
                ? size!
                : (constraints.maxWidth < constraints.maxHeight
                    ? constraints.maxWidth
                    : constraints.maxHeight);
            return Center(
              child: CircularProgressIndicator(
                color: color,
                strokeWidth: finalSize / 5,
              ),
            );
          }),
        ),
      ],
    );
  }
}
