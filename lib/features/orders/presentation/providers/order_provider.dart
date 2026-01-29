import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tapto/core/api/api_client.dart';
import 'package:tapto/core/services/connectivity/network_info.dart';
import 'package:tapto/core/services/hive/hive_services.dart';

import 'package:tapto/features/orders/data/datasource/local/order_localdatasource.dart';
import 'package:tapto/features/orders/data/datasource/remote/order_remote_datasource.dart';
import 'package:tapto/features/orders/data/repository/order_repository_impl.dart';
import 'package:tapto/features/orders/domain/repository/order_repository.dart';

import 'package:tapto/features/orders/domain/usecases/get_my_orders.dart';
import 'package:tapto/features/orders/domain/usecases/get_order_by_id.dart';
import 'package:tapto/features/orders/domain/usecases/track_order.dart';
import 'package:tapto/features/orders/domain/usecases/create_order.dart';
import 'package:tapto/features/orders/domain/usecases/cancel_order.dart';



final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(Connectivity());
});


final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  return OrderRemoteDataSourceImpl(
    apiClient: ref.watch(apiClientProvider),
  );
});

final orderLocalDataSourceProvider = Provider<OrderLocalDataSource>((ref) {
  return OrderLocalDataSourceImpl(
    hiveService: ref.watch(hiveServiceProvider),
  );
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(
    remoteDataSource: ref.watch(orderRemoteDataSourceProvider),
    localDataSource: ref.watch(orderLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});


final getMyOrdersProvider = Provider<GetMyOrders>((ref) {
  return GetMyOrders(ref.watch(orderRepositoryProvider));
});

final getOrderByIdProvider = Provider<GetOrderById>((ref) {
  return GetOrderById(ref.watch(orderRepositoryProvider));
});

final trackOrderProvider = Provider<TrackOrder>((ref) {
  return TrackOrder(ref.watch(orderRepositoryProvider));
});

final createOrderProvider = Provider<CreateOrder>((ref) {
  return CreateOrder(ref.watch(orderRepositoryProvider));
});

final cancelOrderProvider = Provider<CancelOrder>((ref) {
  return CancelOrder(ref.watch(orderRepositoryProvider));
});


