import 'package:flutter/foundation.dart';

import '../models/order.dart';
import '../services/api_service.dart';

class OrdersProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Order> _orders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _error;

  OrdersProvider(this._apiService);

  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _apiService.getOrders();
    } catch (_) {
      _error = 'Не удалось загрузить список заказов';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrder(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedOrder = await _apiService.getOrder(id);
    } catch (_) {
      _error = 'Не удалось загрузить заказ';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> assignDriver(int orderId, int driverId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _apiService.assignDriver(orderId, driverId);
      _selectedOrder = updated;
      _updateInList(updated);
      return true;
    } catch (_) {
      _error = 'Не удалось назначить водителя';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus(int orderId, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _apiService.updateOrderStatus(orderId, status);
      _selectedOrder = updated;
      _updateInList(updated);
      return true;
    } catch (_) {
      _error = 'Не удалось обновить статус заказа';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createOrder({
    required String addressFrom,
    required String addressTo,
    required String clientName,
    required String clientPhone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newOrder = await _apiService.createOrder(
        addressFrom: addressFrom,
        addressTo: addressTo,
        clientName: clientName,
        clientPhone: clientPhone,
      );
      _orders = [newOrder, ..._orders];
      return true;
    } catch (_) {
      _error = 'Не удалось создать заказ';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateInList(Order updated) {
    final idx = _orders.indexWhere((o) => o.id == updated.id);
    if (idx != -1) {
      _orders = List.of(_orders)..[idx] = updated;
    }
  }
}
