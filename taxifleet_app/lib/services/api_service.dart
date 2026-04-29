import 'package:dio/dio.dart';

import '../core/constants/app_constants.dart';
import '../models/car.dart';
import '../models/driver.dart';
import '../models/order.dart';
import 'storage_service.dart';

class ApiService {
  late final Dio _dio;
  final StorageService _storageService;
  void Function()? onUnauthorized;

  ApiService(this._storageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  // ── Drivers ───────────────────────────────────────────────────────────────

  Future<List<Driver>> getDrivers({String? status}) async {
    final response = await _dio.get(
      '/api/drivers',
      queryParameters: status != null ? {'status': status} : null,
    );
    return (response.data as List)
        .map((e) => Driver.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Cars ──────────────────────────────────────────────────────────────────

  Future<List<Car>> getCars() async {
    final response = await _dio.get('/api/cars');
    return (response.data as List)
        .map((e) => Car.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  Future<List<Order>> getOrders() async {
    final response = await _dio.get('/api/orders');
    return (response.data as List)
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Order> getOrder(int id) async {
    final response = await _dio.get('/api/orders/$id');
    return Order.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Order> createOrder({
    required String addressFrom,
    required String addressTo,
    required String clientName,
    required String clientPhone,
  }) async {
    final response = await _dio.post('/api/orders', data: {
      'addressFrom': addressFrom,
      'addressTo': addressTo,
      'clientName': clientName,
      'clientPhone': clientPhone,
    });
    return Order.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Order> assignDriver(int orderId, int driverId) async {
    final response = await _dio.post(
      '/api/orders/$orderId/assign',
      data: {'driverId': driverId},
    );
    return Order.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Order> updateOrderStatus(int orderId, String status) async {
    final response = await _dio.patch(
      '/api/orders/$orderId/status',
      data: {'status': status},
    );
    return Order.fromJson(response.data as Map<String, dynamic>);
  }
}
