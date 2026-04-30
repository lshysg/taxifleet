import 'package:flutter/foundation.dart';

import '../models/car.dart';
import '../services/api_service.dart';

class CarsProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Car> _cars = [];
  bool _isLoading = false;
  String? _error;

  CarsProvider(this._apiService);

  List<Car> get cars => _cars;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCars() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cars = await _apiService.getCars();
    } catch (_) {
      _error = 'Не удалось загрузить список автомобилей';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
