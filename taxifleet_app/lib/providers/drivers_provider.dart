import 'package:flutter/foundation.dart';

import '../models/driver.dart';
import '../services/api_service.dart';

class DriversProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Driver> _drivers = [];
  List<Driver> _freeDrivers = [];
  bool _isLoading = false;
  String? _error;

  DriversProvider(this._apiService);

  List<Driver> get drivers => _drivers;
  List<Driver> get freeDrivers => _freeDrivers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDrivers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _drivers = await _apiService.getDrivers();
    } catch (e) {
      // ignore: avoid_print
      print('ОШИБКА ЗАГРУЗКИ ВОДИТЕЛЕЙ: $e');
      _error = 'Не удалось загрузить список водителей: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFreeDrivers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _freeDrivers = await _apiService.getDrivers(status: 'FREE');
    } catch (_) {
      _error = 'Не удалось загрузить свободных водителей';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
