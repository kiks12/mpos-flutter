// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreDetails _$StoreDetailsFromJson(Map<String, dynamic> json) => StoreDetails(
      name: json['name'] as String,
      contactNumber: json['contactNumber'] as String,
      contactPerson: json['contactPerson'] as String,
    )..id = (json['id'] as num).toInt();

Map<String, dynamic> _$StoreDetailsToJson(StoreDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'contactNumber': instance.contactNumber,
      'contactPerson': instance.contactPerson,
    };
