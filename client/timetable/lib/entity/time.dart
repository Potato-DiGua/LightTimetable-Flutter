import 'package:json_annotation/json_annotation.dart';
import 'package:light_timetable_flutter_app/ext/int_extension.dart';

part 'time.g.dart';

@JsonSerializable()
class TimeEntity {
  Time? start;
  Time? end;

  TimeEntity({this.start, this.end});

  factory TimeEntity.fromJson(Map<String, dynamic> json) =>
      _$TimeEntityFromJson(json);

  Map<String, dynamic> toJson() => _$TimeEntityToJson(this);

  bool get isEmpty => start == null || end == null;

  TimeEntity clone() => TimeEntity(start: this.start, end: this.end);
}

@JsonSerializable()
class Time {
  final int hour;
  final int minute;

  Time({required this.hour, required this.minute});

  factory Time.fromJson(Map<String, dynamic> json) => _$TimeFromJson(json);

  Map<String, dynamic> toJson() => _$TimeToJson(this);

  @override
  String toString() {
    return "${hour.toStringZeroFill(2)}:${minute.toStringZeroFill(2)}";
  }
}
