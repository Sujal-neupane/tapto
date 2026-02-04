import 'package:flutter_test/flutter_test.dart';
import 'package:tapto/features/auth/data/models/user_model.dart';
import 'package:tapto/features/auth/domain/entities/user.dart';

void main() {
  test('UserModel toEntity returns correct User', () {
    final userModel = UserModel(
      id: '1',
      name: 'Test',
      email: 'test@example.com',
      password: 'pass',
      isAdmin: true,
      country: 'USA',
    );
    final user = userModel.toEntity();
    expect(user.id, '1');
    expect(user.name, 'Test');
    expect(user.email, 'test@example.com');
    expect(user.isAdmin, true);
  });



  test('UserModel.fromEntity creates correct UserModel', () {
    final user = User(
      id: '2',
      name: 'Sujal',
      email: 'sujal@example.com',
      isAdmin: false,
      country: 'Nepal',
    );
    final userModel = UserModel.fromEntity(user, 'secret');
    expect(userModel.id, '2');
    expect(userModel.name, 'Sujal');
    expect(userModel.email, 'sujal@example.com');
    expect(userModel.password, 'secret');
    expect(userModel.isAdmin, false);
  });

  
}