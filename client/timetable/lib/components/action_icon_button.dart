import 'package:flutter/material.dart';

class ActionIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? tooltip;
  final Widget icon;

  ActionIconButton({
    required this.icon,
    this.onPressed,
    this.tooltip,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: 16,
      padding: const EdgeInsets.all(5),
      constraints: const BoxConstraints(
        minWidth: 24,
        minHeight: 24,
      ),
      icon: IconTheme.merge(
        data: IconThemeData(size: 24),
        child: icon,
      ),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}
