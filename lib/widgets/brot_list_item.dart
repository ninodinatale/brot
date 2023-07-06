import 'package:flutter/material.dart';

class BrotListItem extends StatelessWidget {
  final Widget leading;
  final Widget? trailing;
  final Widget title;
  final Widget? subtitle;

  const BrotListItem({
    super.key,
    required this.leading,
    this.trailing,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 10,
      child: BrotCardContent(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
      ),
    );
  }
}

class BrotCardContent extends StatelessWidget {
  final Widget leading;
  final Widget? trailing;
  final Widget title;
  final Widget? subtitle;

  const BrotCardContent(
      {Key? key,
      required this.leading,
      required this.trailing,
      required this.title,
      required this.subtitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const height = 70.0;
    const width = 60.0;
    return SizedBox(
      height: height,
      child: Row(
        children: [
          SizedBox(
            width: width,
            height: height,
            child: DefaultTextStyle(
                style: theme.textTheme.titleLarge!, child: leading),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DefaultTextStyle(
                  style: theme.textTheme.titleLarge!, child: title),
              if (subtitle != null)
                DefaultTextStyle(
                    style: theme.textTheme.bodySmall!, child: subtitle!)
            ],
          ),
          if (trailing != null) const Spacer(),
          if (trailing != null)
            SizedBox(
              height: height,
              width: width,
              child: Container(
                color: theme.colorScheme.tertiary.withOpacity(0.8),
                child: Center(
                    child: DefaultTextStyle(
                        style: theme.textTheme.titleLarge!
                            .copyWith(color: theme.colorScheme.onTertiary),
                        child: Center(child: trailing))),
              ),
            ),
        ],
      ),
    );
  }
}
