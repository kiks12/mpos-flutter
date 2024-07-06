// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
      firstName: json['firstName'] as String,
      middleName: json['middleName'] as String,
      lastName: json['lastName'] as String,
      isAdmin: json['isAdmin'] as bool,
      emailAddress: json['emailAddress'] as String,
      contactNumber: json['contactNumber'] as String,
      password: json['password'] as String,
    )..id = (json['id'] as num).toInt();

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'middleName': instance.middleName,
      'lastName': instance.lastName,
      'isAdmin': instance.isAdmin,
      'emailAddress': instance.emailAddress,
      'contactNumber': instance.contactNumber,
      'password': instance.password,
    };
