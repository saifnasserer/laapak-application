import 'package:flutter/material.dart';

/// Navigation Service
///
/// Centralized navigation service for better testability and navigation management.
/// Provides a single point of control for all navigation operations.
class NavigationService {
  NavigationService._();
  static final NavigationService instance = NavigationService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Get current context
  BuildContext? get currentContext => navigatorKey.currentContext;

  /// Get navigator state
  NavigatorState? get navigator => navigatorKey.currentState;

  /// Navigate to a new route
  Future<T?>? push<T extends Object?>(
    Route<T> route, {
    BuildContext? context,
  }) {
    final nav = context != null
        ? Navigator.of(context)
        : navigatorKey.currentState;
    return nav?.push(route);
  }

  /// Navigate to a new route by name
  Future<T?>? pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
    BuildContext? context,
  }) {
    final nav = context != null
        ? Navigator.of(context)
        : navigatorKey.currentState;
    return nav?.pushNamed<T>(routeName, arguments: arguments);
  }

  /// Replace current route with new route
  Future<T?>? pushReplacement<T extends Object?, TO extends Object?>(
    Route<T> newRoute, {
    TO? result,
    BuildContext? context,
  }) {
    final nav = context != null
        ? Navigator.of(context)
        : navigatorKey.currentState;
    return nav?.pushReplacement(newRoute, result: result);
  }

  /// Replace current route with new route by name
  Future<T?>? pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
    BuildContext? context,
  }) {
    final nav = context != null
        ? Navigator.of(context)
        : navigatorKey.currentState;
    return nav?.pushReplacementNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  /// Pop current route
  void pop<T extends Object?>([T? result, BuildContext? context]) {
    final nav = context != null
        ? Navigator.of(context)
        : navigatorKey.currentState;
    nav?.pop(result);
  }

  /// Pop until predicate is true
  void popUntil(
    RoutePredicate predicate, {
    BuildContext? context,
  }) {
    final nav = context != null
        ? Navigator.of(context)
        : navigatorKey.currentState;
    nav?.popUntil(predicate);
  }

  /// Pop until route name
  void popUntilNamed(
    String routeName, {
    BuildContext? context,
  }) {
    popUntil((route) => route.settings.name == routeName, context: context);
  }

  /// Pop to root
  void popToRoot({BuildContext? context}) {
    popUntil((route) => route.isFirst, context: context);
  }

  /// Remove route
  void removeRoute<T extends Object?>(
    Route<T> route, {
    BuildContext? context,
  }) {
    final nav = context != null
        ? Navigator.of(context)
        : navigatorKey.currentState;
    nav?.removeRoute(route);
  }

  /// Remove route below
  void removeRouteBelow<T extends Object?>(
    Route<T> anchorRoute, {
    BuildContext? context,
  }) {
    final nav = context != null
        ? Navigator.of(context)
        : navigatorKey.currentState;
    nav?.removeRouteBelow(anchorRoute);
  }

  /// Can pop
  bool canPop({BuildContext? context}) {
    final nav = context != null
        ? Navigator.of(context)
        : navigatorKey.currentState;
    return nav?.canPop() ?? false;
  }

  /// Maybe pop
  Future<bool> maybePop<T extends Object?>([T? result, BuildContext? context]) {
    final nav = context != null
        ? Navigator.of(context)
        : navigatorKey.currentState;
    return nav?.maybePop(result) ?? Future.value(false);
  }
}


