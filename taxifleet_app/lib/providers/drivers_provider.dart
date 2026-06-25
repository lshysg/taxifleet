import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/driver.dart';
import '../services/api_service.dart';

class DriversProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Driver> _drivers = [];
  List<Driver> _freeDrivers = [];
  bool _isLoading = false;
  bool _fromCache = false;
  String? _error;

  DriversProvider(this._apiService);

  List<Driver> get drivers => _drivers;
  List<Driver> get freeDrivers => _freeDrivers;
  bool get isLoading => _isLoading;
  bool get fromCache => _fromCache;
  String? get error => _error;

  Future<void> loadDrivers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _drivers = await _apiService.getDrivers();
      _fromCache = false;
      final prefs = await SharedPreferences.getInstance();
      final json = _drivers.map((d) => d.toJson()).toList();
      await prefs.setString('cached_drivers', jsonEncode(json));
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_drivers');
      if (cached != null) {
        final list = jsonDecode(cached) as List;
        _drivers = list.map((j) => Driver.fromJson(j as Map<String, dynamic>)).toList();
        _fromCache = true;
        _error = 'Нет соединения — показаны кэшированные данные';
      } else {
        _error = 'Не удалось загрузить список водителей';
      }
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
