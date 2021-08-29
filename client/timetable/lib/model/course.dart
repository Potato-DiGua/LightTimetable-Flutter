import 'package:json_annotation/json_annotation.dart';

part 'course.g.dart';

@JsonSerializable()
class Course extends Comparable<Course> {
  /// 课程名
  String name = "";

  /// 教授名字
  String teacher = "";

  /// 课程时长
  int classLength = 0;

  /// 课程开始节数 值：[1,12]
  int classStart = -1;

  /// 上课地点
  String classRoom = "";

  /// 开始上课的周,用二进制后25位表示是否为本周
  int weekOfTerm = 0;

  /// 在周几上课 值[1,7] 1表示周一
  int dayOfWeek = 0;

  Course(
      {this.name = "",
      this.teacher = "",
      this.classRoom = "",
      this.dayOfWeek = 0,
      this.classStart = -1,
      this.weekOfTerm = 0,
      this.classLength = 0});

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);

  Map<String, dynamic> toJson() => _$CourseToJson(this);

  @override
  int compareTo(Course other) {
    int i = this.dayOfWeek.compareTo(other.dayOfWeek); //首先比较星期
    if (i == 0) //星期相同比较开始上课的时间
    {
      return this.classStart.compareTo(other.classStart);
    } else {
      return i;
    }
  }

  Course clone() {
    return Course(
        name: name,
        teacher: teacher,
        classRoom: classRoom,
        dayOfWeek: dayOfWeek,
        classStart: classStart,
        weekOfTerm: weekOfTerm,
        classLength: classLength);
  }

  int get classEnd => classStart + classLength - 1;
}
