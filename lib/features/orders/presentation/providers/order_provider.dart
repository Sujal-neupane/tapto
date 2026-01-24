
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:tapto/core/api/api_client.dart';
import 'package:tapto/core/services/connectivity/network_info.dart';
import 'package:tapto/core/services/hive/hive_services.dart';
import 'package:tapto/features/orders/data/datasource/local/order_localdatasource.dart';
import 'package:tapto/features/orders/data/datasource/remote/order_remote_datasource.dart';
import 'package:tapto/features/orders/domain/repository/order_repository.dart';
import 'package:tapto/features/orders/data/repository/order_repository_impl.dart';
import 'package:tapto/features/orders/domain/usecases/cancel_order.dart';
import 'package:tapto/features/orders/domain/usecases/create_order.dart';
import 'package:tapto/features/orders/domain/usecases/get_my_orders.dart';
import 'package:tapto/features/orders/domain/usecases/get_order_by_id.dart';
import 'package:tapto/features/orders/domain/usecases/track_order.dart';
import 'package:tapto/features/orders/presentation/state/order_state.dart';
import 'package:tapto/features/orders/presentation/viewmodel/order_viewmodel.dart';

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(Connectivity());
});

// Data Sources
final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  final apiService = ref.watch(apiClientProvider);
  return OrderRemoteDataSourceImpl(apiClient: apiService);
});

final orderLocalDataSourceProvider = Provider<OrderLocalDataSource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return OrderLocalDataSourceImpl(hiveService: hiveService);
});

// Repository
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final remoteDataSource = ref.watch(orderRemoteDataSourceProvider);
  final localDataSource = ref.watch(orderLocalDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);

  return OrderRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
  );
});

// UseCases
final getMyOrdersProvider = Provider<GetMyOrders>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return GetMyOrders(repository);
});

final getOrderByIdProvider = Provider<GetOrderById>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return GetOrderById(repository);
});

final trackOrderProvider = Provider<TrackOrder>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return TrackOrder(repository);
});

final createOrderProvider = Provider<CreateOrder>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return CreateOrder(repository);
});

final cancelOrderProvider = Provider<CancelOrder>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return CancelOrder(repository);
});

// ViewModel
final orderViewModelProvider =
    StateNotifierProvider<OrderViewModel, OrderState>((ref) {
  return OrderViewModel(
    getMyOrders: ref.watch(getMyOrdersProvider),
    getOrderById: ref.watch(getOrderByIdProvider),
    trackOrder: ref.watch(trackOrderProvider),
    createOrder: ref.watch(createOrderProvider),
    cancelOrder: ref.watch(cancelOrderProvider),
  );
});