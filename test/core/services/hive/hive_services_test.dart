
import 'package:flutter_test/flutter_test.dart';
import 'package:tapto/core/services/hive/hive_services.dart';
import 'package:tapto/features/auth/data/models/user_model.dart';
import 'dart:io';

void main() {
  late HiveService hiveService;
  late String testPath;

  setUp(() async {
    testPath = Directory.systemTemp.createTempSync().path;
    hiveService = HiveService();
    await hiveService.init(useFlutter: false, testPath: testPath);
    await hiveService.clearAll();
  });

  tearDown(() async {
    await hiveService.close();
    Directory(testPath).deleteSync(recursive: true);
  });

  test('save and get user', () async { 
    final user = UserModel(
      id: '1',
      name: 'Test User',
      email: 'test@example.com',
      password: 'pass',
      preference: 'Men',
      isAdmin: false,
    );
    await hiveService.saveUser(user);
    final fetched = await hiveService.getUserById('1');
    expect(fetched?.email, 'test@example.com');
  });

  test('clear all users', () async {
    final user = UserModel(
      id: '2',
      name: 'Another',
      email: 'a@b.com',
      password: '123',
      preference: 'Women',
      isAdmin: false, 
    );
    await hiveService.saveUser(user);
    await hiveService.clearAllUsers();
    final all = await hiveService.getAllUsers();
    expect(all.isEmpty, true);
  });
}