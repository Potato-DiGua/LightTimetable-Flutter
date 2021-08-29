import 'package:flutter/material.dart';

class CardView extends StatelessWidget {
  final double? width;
  final double? height;
  final String? title;
  final Widget child;
  final EdgeInsets titlePadding;
  final BorderRadiusGeometry borderRadius;

  CardView(
      {required this.child,
      this.width,
      this.height,
      this.title,
      this.titlePadding = const EdgeInsets.all(16),
      this.borderRadius = const BorderRadius.all(Radius.circular(15))});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration:
          BoxDecoration(borderRadius: borderRadius, color: Colors.white),
      child: _buildChild(),
    );
  }

  Widget _buildChild() {
    if (title == null) {
      return child;
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: titlePadding,
            child: Text(
              title!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          child
        ],
      );
    }
  }
}
