import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cars_provider.dart';
import 'providers/drivers_provider.dart';
import 'providers/orders_provider.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = StorageService();
  await storageService.init();
  final apiService = ApiService(storageService);
  runApp(TaxiFleetApp(storageService: storageService, apiService: apiService));
}

class TaxiFleetApp extends StatefulWidget {
  final StorageService storageService;
  final ApiService apiService;

  const TaxiFleetApp({
    super.key,
    required this.storageService,
    required this.apiService,
  });

  @override
  State<TaxiFleetApp> createState() => _TaxiFleetAppState();
}

class _TaxiFleetAppState extends State<TaxiFleetApp> {
  late final AuthProvider _authProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider(widget.storageService, widget.apiService);
    widget.apiService.onUnauthorized = _authProvider.logout;
    _router = AppRouter.createRouter(_authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(
          create: (_) => DriversProvider(widget.apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => CarsProvider(widget.apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => OrdersProvider(widget.apiService),
        ),
      ],
      child: MaterialApp.router(
        title: 'TaxiFleet Admin',
        theme: AppTheme.lightTheme,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
