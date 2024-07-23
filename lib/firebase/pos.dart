

import 'package:cloud_firestore/cloud_firestore.dart';

class POS {
  final String name;
  final String device;
  final String serialNumber;

  POS({
    required this.name,
    required this.device,
    required this.serialNumber,
  });

  factory POS.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return POS(
      name: data?['name'],
      device: data?['device'],
      serialNumber: data?['serialNumber'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "device": device,
      "serialNumber": serialNumber,
    };
  }
}
