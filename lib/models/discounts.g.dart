// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discounts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Discount _$DiscountFromJson(Map<String, dynamic> json) => Discount(
      title: json['title'] as String,
      operation: json['operation'] as String,
      value: (json['value'] as num).toInt(),
      type: json['type'] as String,
      category: json['category'] as String,
      products: json['products'] as String,
    )..id = (json['id'] as num).toInt();

Map<String, dynamic> _$DiscountToJson(Discount instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'type': instance.type,
      'category': instance.category,
      'products': instance.products,
      'operation': instance.operation,
      'value': instance.value,
    };
