// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expiration_dates.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpirationDate _$ExpirationDateFromJson(Map<String, dynamic> json) =>
    ExpirationDate(
      date: DateTime.parse(json['date'] as String),
      quantity: (json['quantity'] as num).toInt(),
      sold: (json['sold'] as num).toInt(),
      expired: (json['expired'] as num).toInt(),
    )..id = (json['id'] as num).toInt();

Map<String, dynamic> _$ExpirationDateToJson(ExpirationDate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'quantity': instance.quantity,
      'sold': instance.sold,
      'expired': instance.expired,
    };
