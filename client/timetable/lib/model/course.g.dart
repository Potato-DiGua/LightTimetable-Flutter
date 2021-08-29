// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Course _$CourseFromJson(Map<String, dynamic> json) {
  return Course(
    name: json['name'] as String,
    teacher: json['teacher'] as String,
    classRoom: json['classRoom'] as String,
    dayOfWeek: json['dayOfWeek'] as int,
    classStart: json['classStart'] as int,
    weekOfTerm: json['weekOfTerm'] as int,
    classLength: json['classLength'] as int,
  );
}

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
      'name': instance.name,
      'teacher': instance.teacher,
      'classLength': instance.classLength,
      'classStart': instance.classStart,
      'classRoom': instance.classRoom,
      'weekOfTerm': instance.weekOfTerm,
      'dayOfWeek': instance.dayOfWeek,
    };
