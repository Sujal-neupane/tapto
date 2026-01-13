import 'package:equatable/equatable.dart';

/// User entity representing a user in the domain layer
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? preference; // Shopping preference (Men/Women)
  final String? profilePicture;
  final String? phoneNumber;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.preference,
    this.profilePicture,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [id, name, email, preference, profilePicture];
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? preference,
    String? profilePicture,
    String? phoneNumber,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      preference: preference ?? this.preference,
      profilePicture: profilePicture ?? this.profilePicture,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
