import 'package:equatable/equatable.dart';

/// Parameters for login use case
class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Parameters for register use case
class RegisterParams extends Equatable {
  final String name;
  final String email;
  final String password;
  final String? preference;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    this.preference,
  });

  @override
  List<Object?> get props => [name, email, password, preference];
}
