import 'package:flutter/material.dart';

class ItemButton extends StatelessWidget {
  final GestureTapCallback? onClick;
  final Icon icon;
  final String title;

  const ItemButton({
    required this.icon,
    required this.title,
    this.onClick,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onClick,
          child: Container(
            constraints: BoxConstraints(minHeight: 64, minWidth: 64),
            padding: const EdgeInsets.all(3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconTheme.merge(
                  data: IconThemeData(size: 24),
                  child: icon,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 13),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
