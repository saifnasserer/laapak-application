import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/auth/login_screen.dart';
import 'screens/order/order_screen.dart';
import 'theme/theme.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const ProviderScope(child: LaapakApp()));
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
        darkTheme: LaapakTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Laapak',
      debugShowCheckedModeBanner: false,
      theme: LaapakTheme.lightTheme,
      darkTheme: LaapakTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: authState.isAuthenticated
          ? const OrderScreen()
          : const LoginScreen(),
    );
  }
}
