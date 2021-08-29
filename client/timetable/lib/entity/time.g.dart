// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeEntity _$TimeEntityFromJson(Map<String, dynamic> json) {
  return TimeEntity(
    start: json['start'] == null
        ? null
        : Time.fromJson(json['start'] as Map<String, dynamic>),
    end: json['end'] == null
        ? null
        : Time.fromJson(json['end'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$TimeEntityToJson(TimeEntity instance) =>
    <String, dynamic>{
      'start': instance.start,
      'end': instance.end,
    };

Time _$TimeFromJson(Map<String, dynamic> json) {
  return Time(
    hour: json['hour'] as int,
    minute: json['minute'] as int,
  );
}

Map<String, dynamic> _$TimeToJson(Time instance) => <String, dynamic>{
      'hour': instance.hour,
      'minute': instance.minute,
    };
