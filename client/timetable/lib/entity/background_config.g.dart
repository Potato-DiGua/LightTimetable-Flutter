// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackgroundConfig _$BackgroundConfigFromJson(Map<String, dynamic> json) {
  return BackgroundConfig(
    type: _$enumDecode(_$BackgroundTypeEnumMap, json['type']),
    color: json['color'] as int?,
    imgPath: json['imgPath'] as String?,
  );
}

Map<String, dynamic> _$BackgroundConfigToJson(BackgroundConfig instance) =>
    <String, dynamic>{
      'type': _$BackgroundTypeEnumMap[instance.type],
      'color': instance.color,
      'imgPath': instance.imgPath,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$BackgroundTypeEnumMap = {
  BackgroundType.defaultBg: 'defaultBg',
  BackgroundType.color: 'color',
  BackgroundType.img: 'img',
};
