import 'package:flutter/material.dart';

import 'package:antic_frontend/services/api_client.dart';

class AppScope extends InheritedWidget {
  final ApiClient api;
  final String baseUrl;
  final VoidCallback refreshAll;

  const AppScope({
    super.key,
    required this.api,
    required this.baseUrl,
    required this.refreshAll,
    required super.child,
  });

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return oldWidget.baseUrl != baseUrl || oldWidget.api != api;
  }
}
