// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sale _$SaleFromJson(Map<String, dynamic> json) => Sale(
      transactionID: json['transactionID'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      locationId: json['locationId'] as String,
      locationName: json['locationName'] as String,
      paymentMethod: json['paymentMethod'] as String,
      subTotal: (json['subTotal'] as num).toInt(),
      discount: (json['discount'] as num).toInt(),
      totalAmount: (json['totalAmount'] as num).toInt(),
      payment: (json['payment'] as num).toInt(),
      change: (json['change'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      time: DateTime.parse(json['time'] as String),
      referenceNumber: json['referenceNumber'] as String? ?? "",
      packagesJson: json['packagesJson'] as String? ?? "",
      productsJson: json['productsJson'] as String? ?? "",
      synced: json['synced'] as bool? ?? false,
    )..id = (json['id'] as num).toInt();

Map<String, dynamic> _$SaleToJson(Sale instance) => <String, dynamic>{
      'id': instance.id,
      'transactionID': instance.transactionID,
      'employeeId': instance.employeeId,
      'employeeName': instance.employeeName,
      'locationId': instance.locationId,
      'locationName': instance.locationName,
      'packagesJson': instance.packagesJson,
      'productsJson': instance.productsJson,
      'paymentMethod': instance.paymentMethod,
      'referenceNumber': instance.referenceNumber,
      'subTotal': instance.subTotal,
      'discount': instance.discount,
      'totalAmount': instance.totalAmount,
      'payment': instance.payment,
      'change': instance.change,
      'date': instance.date.toIso8601String(),
      'time': instance.time.toIso8601String(),
      'synced': instance.synced,
    };
