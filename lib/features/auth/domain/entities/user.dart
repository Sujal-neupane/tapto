import 'package:equatable/equatable.dart';

/// User entity representing a user in the domain layer
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? preference; // Shopping preference (Men/Women)
  final String? profilePicture;
  final String? phoneNumber;
  final bool isAdmin;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.preference,
    this.profilePicture,
    this.phoneNumber,
    this.isAdmin = false,
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
    bool? isAdmin,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      preference: preference ?? this.preference,
      profilePicture: profilePicture ?? this.profilePicture,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
