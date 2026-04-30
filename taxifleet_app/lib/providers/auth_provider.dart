import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final StorageService _storageService;
  final ApiService _apiService;

  bool _isAuthenticated = false;
  String? _adminName;
  int? _adminId;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._storageService, this._apiService) {
    _restoreSession();
  }

  bool get isAuthenticated => _isAuthenticated;
  String? get adminName => _adminName;
  int? get adminId => _adminId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _restoreSession() {
    final token = _storageService.getToken();
    if (token != null) {
      _isAuthenticated = true;
      _adminName = _storageService.getAdminName();
      _adminId = _storageService.getAdminId();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.login(email, password);
      final token = data['token'] as String;
      final adminId = data['adminId'] as int;
      final name = data['name'] as String;

      await _storageService.saveToken(token);
      await _storageService.saveAdminData(adminId: adminId, name: name);

      _isAuthenticated = true;
      _adminName = name;
      _adminId = adminId;
      _error = null;
    } catch (e) {
      _error = _parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storageService.clear();
    _isAuthenticated = false;
    _adminName = null;
    _adminId = null;
    notifyListeners();
  }

  String _parseError(Object e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return 'Нет соединения с сервером';
        default:
          break;
      }
      final statusCode = e.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        return 'Неверный email или пароль';
      }
      final message = e.response?.data?['message'];
      if (message is String) return message;
      return 'Ошибка сервера (${statusCode ?? 'нет ответа'})';
    }
    return 'Неизвестная ошибка';
  }
}
