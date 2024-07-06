// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageProduct _$ImageProductFromJson(Map<String, dynamic> json) => ImageProduct(
      id: (json['id'] as num?)?.toInt() ?? 0,
      path: json['path'] as String,
    );

Map<String, dynamic> _$ImageProductToJson(ImageProduct instance) =>
    <String, dynamic>{
      'id': instance.id,
      'path': instance.path,
    };

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String,
      category: json['category'] as String,
      unitPrice: (json['unitPrice'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      totalPrice: (json['totalPrice'] as num).toInt(),
      image: json['image'] as String,
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'unitPrice': instance.unitPrice,
      'quantity': instance.quantity,
      'totalPrice': instance.totalPrice,
      'image': instance.image,
    };

PackagedProduct _$PackagedProductFromJson(Map<String, dynamic> json) =>
    PackagedProduct(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String,
      category: json['category'] as String,
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toInt(),
      products: json['products'] as String,
      image: json['image'] as String,
    );

Map<String, dynamic> _$PackagedProductToJson(PackagedProduct instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'quantity': instance.quantity,
      'price': instance.price,
      'image': instance.image,
      'products': instance.products,
    };
