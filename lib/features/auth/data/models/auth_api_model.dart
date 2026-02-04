import 'package:tapto/features/auth/domain/entities/user.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String password;
  final String? preference;
  final String phoneNumber;
  final String? profilePicture;
  final bool isAdmin;
  final String country;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.password,
    this.preference,
    required this.phoneNumber,
    this.profilePicture,
    this.isAdmin = false,
    required this.country,
  });

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'password': password,
      'shoppingPreference': preference,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'isAdmin': isAdmin,
      'country': country,
    };
  }

  // fromJson
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id'] as String? ?? json['id'] as String?,
      fullName: json['fullName'] as String? ?? json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      preference:
          json['shoppingPreference'] as String? ??
          json['preference'] as String?,
      phoneNumber: json['phoneNumber'] as String? ?? '',
      profilePicture: json['profilePicture'] as String?,
      isAdmin: json['isAdmin'] as bool? ?? false,
      country: json['country'] as String? ?? 'United States',
    );
  }

  // toEntity
  User toEntity() {
    return User(
      id: id ?? '',
      name: fullName,
      email: email,
      preference: preference,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
      isAdmin: isAdmin,
      country: country,
    );
  }

  factory AuthApiModel.fromEntity(User user, {String password = ''}) {
    return AuthApiModel(
      id: user.id,
      fullName: user.name,
      email: user.email,
      password: password,
      preference: user.preference,
      phoneNumber: user.phoneNumber ?? '',
      profilePicture: user.profilePicture,
      isAdmin: user.isAdmin,
      country: user.country ?? 'United States',
    );
  }

  //toEntityList
  static List<User> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
