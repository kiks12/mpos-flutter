
class Employee {
  final String id;
  final String userId;
  final String name;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  Employee({
    required this.id,
    required this.userId,
    required this.name,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'address': address,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

