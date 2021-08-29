import 'package:flutter/material.dart';

class TextUtil {
  TextUtil._();

  static bool isEmpty(String? text) {
    return text?.isEmpty ?? true;
  }

  static bool isNotEmpty(String? text) {
    return !isEmpty(text);
  }

  static String isEmptyOrDefault(String? text, String defaultStr) {
    return isEmpty(text) ? defaultStr : text!;
  }

  /// [value] : 文本内容
  /// [fontSize] : 文字的大小
  /// [fontWeight] : 文字权重
  /// [maxWidth] : 文本框的最大宽度
  /// [maxLines] : 文本支持最大多少行
  /// [context] : 当前界面上下文
  static TextPainter buildTextPainter(
      BuildContext context,
      //GlobalStatic.context
      String value,
      double fontSize,
      double maxWidth,
      {FontWeight? fontWeight = FontWeight.normal,
      int? maxLines}) {
    TextPainter painter = TextPainter(
      /// 华为手机如果不指定locale的时候，该方法算出来的文字高度是比系统计算偏小的。
      locale: Localizations.localeOf(context),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: value,
        style: Theme.of(context).textTheme.bodyText2?.merge(
                  TextStyle(
                    fontWeight: fontWeight,
                    fontSize: fontSize,
                  ),
                ) ??
            TextStyle(
              fontWeight: fontWeight,
              fontSize: fontSize,
            ),
      ),
    );
    //设置layout
    painter.layout(maxWidth: maxWidth);
    //文字的Size
    return painter;
  }

  static Size calculateTextSize(
      BuildContext context, //GlobalStatic.context
      String value,
      double fontSize,
      double maxWidth,
      {FontWeight? fontWeight,
      int? maxLines}) {
    return buildTextPainter(context, value, fontSize, maxWidth,
            fontWeight: fontWeight, maxLines: maxLines)
        .size;
  }

  static double calculateTextHeight(
      BuildContext context, //GlobalStatic.context
      String value,
      double fontSize,
      double maxWidth,
      {FontWeight? fontWeight,
      int? maxLines}) {
    return calculateTextSize(context, value, fontSize, maxWidth,
            fontWeight: fontWeight, maxLines: maxLines)
        .height;
  }
}
