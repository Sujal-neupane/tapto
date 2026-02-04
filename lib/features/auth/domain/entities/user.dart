import 'package:equatable/equatable.dart';

/// User entity representing a user in the domain layer
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? preference; // Shopping preference (Men/Women)
  final String? profilePicture;
  final String? phoneNumber;
  final String? country; // Country for currency and payment methods
  final bool isAdmin;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.preference,
    this.profilePicture,
    this.phoneNumber,
    this.country,
    this.isAdmin = false,
  });

  @override
  List<Object?> get props => [id, name, email, preference, profilePicture, phoneNumber, country];
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? preference,
    String? profilePicture,
    String? phoneNumber,
    String? country,
    bool? isAdmin,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      preference: preference ?? this.preference,
      profilePicture: profilePicture ?? this.profilePicture,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      country: country ?? this.country,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
