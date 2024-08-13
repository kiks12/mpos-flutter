import 'dart:convert';

import 'package:mpos/models/expiration_dates.dart';
import 'package:mpos/models/ingredient.dart';
import 'package:objectbox/objectbox.dart';
import 'package:json_annotation/json_annotation.dart';

part 'inventory.g.dart';

@Entity()
@JsonSerializable()
class ImageProduct {
  int id=0;
  String path;

  ImageProduct({
    this.id = 0,
    required this.path
  });

  factory ImageProduct.fromJson(Map<String, dynamic> json) => _$ImageProductFromJson(json);
  Map<String, dynamic> toJson() => _$ImageProductToJson(this);

  @override
  String toString() {
    return "Image $path";
  }
}

@Entity()
@JsonSerializable()
class ProductVariant {
  int id = 0;
  String name;
  int unitPrice;
  int quantity;
  int totalPrice;
  String image;

  final product = ToOne<Product>();

  @Backlink('productVariantExp')
  final expirationDates = ToMany<ExpirationDate>();

  factory ProductVariant.fromJson(Map<String, dynamic> json) => _$ProductVariantFromJson(json);
  Map<String, dynamic> toJson() => _$ProductVariantToJson(this);

  ProductVariant({this.id = 0, required this.name, required this.unitPrice, required this.quantity, required this.totalPrice, required this.image});
}

@Entity()
@JsonSerializable()
class Product {
  int id = 0;
  String name;
  String category;
  int unitPrice;
  int quantity;
  bool withVariant;
  int totalPrice;
  String image;

  @Backlink('product')
  final variants = ToMany<ProductVariant>();

  @Backlink('product')
  final ingredients = ToMany<Ingredient>();

  @Backlink('productExp')
  final expirationDates = ToMany<ExpirationDate>();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'category': category,
    'withVariant': withVariant,
    'unitPrice': unitPrice,
    'quantity': quantity,
    'totalPrice': totalPrice
  };

  static Product fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    category: json['category'],
    unitPrice: json['unitPrice'],
    quantity: json['quantity'],
    totalPrice: json['totalPrice'],
    image: json['image'],
    withVariant: json['withVariant'],
  );

  factory Product.fromJsonSerial(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJsonSerial() => _$ProductToJson(this);

  Product({
    this.id = 0,
    required this.name,
    required this.category,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    required this.image,
    this.withVariant = false,
  });

  @override
  String toString() {
    return 'Product {$id, $name, $image, $category,$unitPrice, $quantity, $totalPrice}';
  }
}

@Entity()
@JsonSerializable()
class PackagedProduct {
  int id = 0;
  String name;
  String category;
  int quantity;
  int price = 0;
  String image;

  String products;

  List<Product> get productsList => (jsonDecode(products) as List).map((e) => Product.fromJson(e)).toList();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'quantity': quantity,
    'price': price,
    'products': productsList,
    'image': image
  };

  static PackagedProduct fromJson(Map<String, dynamic> json) => PackagedProduct(
    id: json['id'],
    name: json['name'],
    category: json['category'],
    quantity: json['quantity'],
    price: json['price'],
    products: jsonEncode(json['products']),
    image: json['image'],
  );

  void clear() {
    final productsList = [];
    products = jsonEncode(productsList);
  }

  void addProduct(Product product) {
    final productsList = (jsonDecode(products) as List).map((e) => Product.fromJson(e)).toList();
    productsList.add(product);
    products = jsonEncode(productsList.map((e) => e.toJson()).toList());
  }

  void removeProduct(int index) {
    final productsList = (jsonDecode(products) as List).map((e) => Product.fromJson(e)).toList();
    productsList.removeAt(index);
    products = jsonEncode(productsList.map((e) => e.toJson()).toList());
  }

  PackagedProduct({
    this.id = 0,
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
    required this.products,
    required this.image,
  });

  factory PackagedProduct.fromJsonSerial(Map<String, dynamic> json) => _$PackagedProductFromJson(json);
  Map<String, dynamic> toJsonSerial() => _$PackagedProductToJson(this);

  @override
  String toString() {
    return "Packaged Product {$id, $name, $image, $products, $category, $quantity, $price}";
  }
}
