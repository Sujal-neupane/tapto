import 'package:equatable/equatable.dart';

/// User entity representing a user in the domain layer
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? preference; // Shopping preference (Men/Women)
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.preference,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, email, preference, createdAt];

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? preference,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      preference: preference ?? this.preference,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
