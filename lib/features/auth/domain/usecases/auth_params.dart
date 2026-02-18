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
  final String country;
  final String? phoneNumber;
  final String? currency;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    this.preference,
    required this.country,
    this.phoneNumber,
    this.currency,
  });

  @override
  List<Object?> get props => [name, email, password, preference, country, phoneNumber];
}
