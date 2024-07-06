// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
      transactionID: (json['transactionID'] as num).toInt(),
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
    )..id = (json['id'] as num).toInt();

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transactionID': instance.transactionID,
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
    };
