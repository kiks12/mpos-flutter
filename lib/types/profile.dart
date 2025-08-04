

import 'package:supabase_flutter/supabase_flutter.dart';

class Profile {
  late String id;
  late String userId;
  late String email;
  late String fullName;
  late String businessName;
  late DateTime createdAt;
  late DateTime updatedAt;

  Profile({
    required this.id,
    required this.userId,
    required this.email,
    required this.fullName,
    required this.businessName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromSupabaseRes(PostgrestMap map) {
    return Profile(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      email: map['email'] as String,
      fullName: map['full_name'] as String,
      businessName: map['business_name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'email': email,
    'name': fullName,
    'business_name': businessName,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  @override
  String toString() {
    return 'id: $id, userId: $userId, email: $email, fullName: $fullName, businessName: $businessName, createdAt: ${createdAt.toString()}, updatedAt: ${updatedAt.toString()}';
  }
}