extension IntExtension on int {
  /// 位数不足前面补0
  String toStringZeroFill(int length) {
    String text = this.toString();
    if (text.length >= length) {
      return text;
    } else {
      final stringBuffer = StringBuffer();
      for (var i = text.length; i < length; ++i) {
        stringBuffer.write(0);
      }
      stringBuffer.write(text);
      return stringBuffer.toString();
    }
  }
}
