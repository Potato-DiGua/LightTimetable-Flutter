import 'package:flutter/material.dart';

// 底部贝塞尔曲线切割
class BottomCurveClipper extends CustomClipper<Path> {
  /// 切割点与底部的距离
  final double offset;

  BottomCurveClipper({this.offset = 20});

  @override
  Path getClip(Size size) {
    double top = 0;
    double right = size.width;
    double left = 0;
    double bottom = size.height - offset;

    var path = Path();
    path.lineTo(left, top); // 第一个点，左上角
    path.lineTo(left, bottom); // 左下角

    path.quadraticBezierTo(
        size.width / 2, // 控制点
        size.height, // 控制点
        right, //右下角
        bottom); //右下角

    path.lineTo(right, 0); // 右上角

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    if (oldClipper.runtimeType != BottomCurveClipper) return true;
    final BottomCurveClipper typedOldClipper = oldClipper as BottomCurveClipper;
    return offset != typedOldClipper.offset;
  }
}
