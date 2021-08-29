import 'package:json_annotation/json_annotation.dart';

part 'background_config.g.dart';

enum BackgroundType {
  /// 默认
  defaultBg,

  /// 纯色
  color,

  /// 图片
  img
}

@JsonSerializable()
class BackgroundConfig {
  /// 背景类型
  BackgroundType type;

  /// 颜色
  int? color;

  /// 图片路径
  String? imgPath;

  BackgroundConfig({required this.type, this.color, this.imgPath});

  factory BackgroundConfig.fromJson(Map<String, dynamic> json) =>
      _$BackgroundConfigFromJson(json);

  Map<String, dynamic> toJson() => _$BackgroundConfigToJson(this);
}
