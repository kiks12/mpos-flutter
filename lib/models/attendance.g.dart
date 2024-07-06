// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attendance _$AttendanceFromJson(Map<String, dynamic> json) => Attendance(
      date: DateTime.parse(json['date'] as String),
      timeIn: DateTime.parse(json['timeIn'] as String),
      timeOut: json['timeOut'] == null
          ? null
          : DateTime.parse(json['timeOut'] as String),
    )..id = (json['id'] as num).toInt();

Map<String, dynamic> _$AttendanceToJson(Attendance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'timeIn': instance.timeIn.toIso8601String(),
      'timeOut': instance.timeOut?.toIso8601String(),
    };
