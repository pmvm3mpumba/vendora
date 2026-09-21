import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  client,
  seller;

  String get label => this == UserRole.client ? 'Client' : 'Vendeur';

  static UserRole parse(String value) => switch (value) {
    'client' => UserRole.client,
    'seller' => UserRole.seller,
    _ => throw const FormatException('Rôle utilisateur inconnu'),
  };
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.whatsappNumber,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String whatsappNumber;
  final DateTime? createdAt;

  bool get isSeller => role == UserRole.seller;

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      name: data['name'] as String,
      email: data['email'] as String,
      phone: data['phone'] as String,
      role: UserRole.parse(data['role'] as String),
      whatsappNumber: data['whatsappNumber'] as String,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
