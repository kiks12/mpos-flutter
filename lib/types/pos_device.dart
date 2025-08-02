
import 'package:supabase_flutter/supabase_flutter.dart';

class PosDevice {
  late String id;
  late String userId;
  late String locationId;
  late String name;
  late String deviceToken;
  late bool isActive;
  late DateTime createdAt;
  late DateTime updatedAt;

  PosDevice({
    required this.id,
    required this.userId,
    required this.locationId,
    required this.name,
    required this.deviceToken,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PosDevice.fromSupabaseRes(PostgrestMap map) {
    return PosDevice(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      locationId: map['location_id'] as String,
      name: map['name'] as String,
      deviceToken: map['device_token'] as String,
      isActive: map['is_active'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'location_id': locationId,
    'name': name,
    'device_token': deviceToken,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}