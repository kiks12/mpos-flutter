import 'package:objectbox/objectbox.dart';
import 'package:json_annotation/json_annotation.dart';

part 'store_details.g.dart';

@Entity()
@JsonSerializable()
class StoreDetails {
  int id = 0;
  String name;
  String contactNumber;
  String contactPerson;

  StoreDetails({
    required this.name,
    required this.contactNumber,
    required this.contactPerson,
  });

  factory StoreDetails.fromJson(Map<String, dynamic> json) => _$StoreDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$StoreDetailsToJson(this);

  @override
  String toString() {
    return 'Store Details {$id, $name, $contactNumber, $contactPerson}';
  }
}
