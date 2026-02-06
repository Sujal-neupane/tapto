import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/api/api_client.dart';
import 'package:tapto/features/admin/data/remote/driver_remote_datasource.dart';

final driverRemoteDataSourceProvider = Provider<DriverRemoteDataSource>((ref) {
  return DriverRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

final driversProvider = FutureProvider((ref) async {
  final dataSource = ref.watch(driverRemoteDataSourceProvider);
  return dataSource.getAllDrivers();
});
