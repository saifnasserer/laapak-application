import 'package:flutter/material.dart';
import 'screens/order/order_screen.dart';
import 'theme/theme.dart';

void main() {
  runApp(const LaapakApp());
}

class LaapakApp extends StatelessWidget {
  const LaapakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laapak',
      debugShowCheckedModeBanner: false,
      theme: LaapakTheme.lightTheme,
      darkTheme: LaapakTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const OrderScreen(),
    );
  }
}
