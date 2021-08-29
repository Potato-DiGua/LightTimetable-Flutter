
import 'package:flutter/material.dart';

class MenuItemView extends StatelessWidget {
  final double height;
  final Widget? child;
  final Icon? icon;
  final String label;
  final GestureTapCallback? onClick;

  MenuItemView(
      {required this.label,
      this.icon,
      this.height = 48.0,
      this.child,
      this.onClick});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        color: Colors.white,
        constraints: BoxConstraints(minHeight: height),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconTheme.merge(
                    data: IconThemeData(size: 24), child: icon!),
              ),
            Text(
              label,
              style: TextStyle(fontSize: 16),
            ),
            if (child != null) Expanded(child: Container()),
            if (child != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: child!,
              )
          ],
        ),
      ),
    );
  }
}
