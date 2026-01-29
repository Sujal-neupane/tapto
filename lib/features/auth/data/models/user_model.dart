import 'package:hive/hive.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

/// User model for data layer with Hive annotations
@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String password; // Hashed password stored locally

  @HiveField(4)
  final String? preference;

  @HiveField(5)
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.preference,
    this.isAdmin = false,
  });

  /// Convert to domain entity
  User toEntity() {
    return User(id: id, name: name, email: email, preference: preference, isAdmin: isAdmin);
  }

  /// Create from domain entity
  factory UserModel.fromEntity(User user, String password) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      password: password,
      preference: user.preference,
      isAdmin: user.isAdmin,
    );
  }

  /// Create a new user registration
  factory UserModel.register({
    required String name,
    required String email,
    required String password,
    String? preference,
    String? id,
  }) {
    return UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      password: password,
      preference: preference,
      isAdmin: false,
    );
  }

  /// Verify password
  bool verifyPassword(String inputPassword) {
    return password == inputPassword;
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? preference,
    bool? isAdmin,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      preference: preference ?? this.preference,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
