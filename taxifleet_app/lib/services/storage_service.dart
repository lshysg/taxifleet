import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';

class StorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }

  String? getToken() => _prefs.getString(AppConstants.tokenKey);

  Future<void> saveAdminData({
    required int adminId,
    required String name,
  }) async {
    await _prefs.setInt(AppConstants.adminIdKey, adminId);
    await _prefs.setString(AppConstants.adminNameKey, name);
  }

  int? getAdminId() => _prefs.getInt(AppConstants.adminIdKey);
  String? getAdminName() => _prefs.getString(AppConstants.adminNameKey);

  Future<void> clear() async {
    await _prefs.clear();
  }
}
