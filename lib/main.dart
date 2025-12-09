import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/auth/login_screen.dart';
import 'screens/order/order_screen.dart';
import 'theme/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'services/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  final container = ProviderContainer();
  container.read(initializeNotificationsProvider);

  runApp(
    UncontrolledProviderScope(container: container, child: const LaapakApp()),
  );
}

class LaapakApp extends ConsumerWidget {
  const LaapakApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Show loading screen while checking session
    if (authState.isLoading) {
      return MaterialApp(
        title: 'Laapak',
        debugShowCheckedModeBanner: false,
        theme: LaapakTheme.lightTheme,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Laapak',
      debugShowCheckedModeBanner: false,
      theme: LaapakTheme.lightTheme,
      navigatorKey: NavigationService.instance.navigatorKey,
      home: authState.isAuthenticated
          ? const OrderScreen()
          : const LoginScreen(),
    );
  }
}
