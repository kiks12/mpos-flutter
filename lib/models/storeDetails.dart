import 'package:objectbox/objectbox.dart';

@Entity()
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

  @override
  String toString() {
    return 'Store Details {$id, $name, $contactNumber, $contactPerson}';
  }
}
