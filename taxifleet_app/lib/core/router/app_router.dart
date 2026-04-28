import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../screens/assign/assign_driver_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/orders/order_detail_screen.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isLoginRoute = state.matchedLocation == '/login';

        if (!isLoggedIn && !isLoginRoute) return '/login';
        if (isLoggedIn && isLoginRoute) return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/orders/:id',
          builder: (context, state) => OrderDetailScreen(
            orderId: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/orders/:id/assign',
          builder: (context, state) => AssignDriverScreen(
            orderId: int.parse(state.pathParameters['id']!),
          ),
        ),
      ],
    );
  }
}
