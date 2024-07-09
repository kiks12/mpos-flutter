
import 'package:cloud_firestore/cloud_firestore.dart';

class Store {
  final String storeName;
  final String address;
  final String contactPerson;
  final String contactNumber;

  Store({
    required this.storeName,
    required this.address,
    required this.contactPerson,
    required this.contactNumber
  });

  factory Store.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Store(
      storeName: data?['storeName'],
      address: data?['address'],
      contactPerson: data?['contactPerson'],
      contactNumber: data?['contactNumber'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "storeName": storeName,
      "address": address,
      "contactPerson": contactPerson,
      "contactNumber": contactNumber,
    };
  }
}