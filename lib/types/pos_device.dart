import 'package:mpos/types/location.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PosDevice {
  final String id;
  final String userId;
  final String locationId;
  final String name;
  final String deviceToken;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Location? location; // Optional embedded location

  PosDevice({
    required this.id,
    required this.userId,
    required this.locationId,
    required this.name,
    required this.deviceToken,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.location,
  });

  factory PosDevice.fromSupabaseRes(PostgrestMap map) {
    return PosDevice(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      locationId: map['location_id'] as String,
      name: map['name'] as String,
      deviceToken: map['device_token'] as String,
      isActive: map['is_active'] as bool,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      location: map['locations'] != null
          ? Location.fromMap(map['locations'] as Map<String, dynamic>)
          : null,
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
    'location': location?.toJson(),
  };
}
