import 'package:tapto/core/api/api_client.dart';

class DriverModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String vehicleNumber;
  final String? avatarUrl;

  DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.vehicleNumber,
    this.avatarUrl,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      avatarUrl: json['avatarUrl'],
    );
  }
}

abstract class DriverRemoteDataSource {
  Future<List<DriverModel>> getAllDrivers();
  Future<void> assignDriverToOrder(String orderId, String driverId);
}

class DriverRemoteDataSourceImpl implements DriverRemoteDataSource {
  final ApiClient apiClient;
  DriverRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<DriverModel>> getAllDrivers() async {
    final response = await apiClient.get('/api/drivers');
    final data = response.data;
    if (data is Map && data['data'] != null) {
      return (data['data'] as List)
          .map((json) => DriverModel.fromJson(json))
          .toList();
    }
    return (data as List).map((json) => DriverModel.fromJson(json)).toList();
  }

  @override
  Future<void> assignDriverToOrder(String orderId, String driverId) async {
    await apiClient.patch(
      '/api/admin/orders/$orderId/assign-driver',
      data: {'driverId': driverId},
    );
  }
}
