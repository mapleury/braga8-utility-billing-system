import 'package:flutter/material.dart';
import 'package:braga8_mobile/ApiService.dart';
import 'package:braga8_mobile/views/splash/splash_screen.dart';
import 'package:braga8_mobile/views/onboarding/onboarding_screen.dart';
import 'package:braga8_mobile/views/sign_in/sign_in_screen.dart';
import 'package:braga8_mobile/views/dashboard/dashboard_screen.dart';
import 'package:braga8_mobile/views/daftar_unit/daftar_unit_screen.dart';
import 'package:braga8_mobile/views/daftar_unit/detail_unit_screen.dart';
import 'package:braga8_mobile/views/daftar_unit/meter_reading_screen.dart';
import 'package:braga8_mobile/views/meter_input/input_reading_screen.dart';
import 'package:braga8_mobile/views/history/audit_log_screen.dart';
import 'package:braga8_mobile/data/models/tenant_model.dart';

class AppRouter {
  final ApiService api;
  AppRouter(this.api);

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _build(settings, const SplashScreen());

      case '/onboarding':
        return _build(settings, const OnboardingScreen());

      case '/login':
        return _build(settings, const SignInScreen());

      case '/dashboard':
        final args = settings.arguments as Map<String, dynamic>;
        return _build(
          settings,
          DashboardScreen(api: api, token: args['token'], role: args['role']),
        );

      case '/daftar-unit':
        return _build(settings, DaftarUnitScreen(api: api));

      case '/detail-unit':
        final args = settings.arguments as Map<String, dynamic>;
        return _build(
          settings,
          DetailUnitScreen(
            shopName: args['shopName'],
            unit: args['unit'] as Unit,
          ),
        );

      case '/meter-history':
        final args = settings.arguments as Map<String, dynamic>;
        return _build(
          settings,
          MeterHistoryScreen(
            unitId: args['unitId'],
            unitNumber: args['unitNumber'],
            unit: args['unit'] as Unit?,
          ),
        );

      case '/input-reading':
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _build(
          settings,
          InputReadingScreen(
            unit: args['unit'] as Unit?,
            category: args['category'] as String?,
            isEdit: args['isEdit'] as bool? ?? false,
            initialValue: args['initialValue'] as String?,
          ),
        );

      case '/audit-log':
        return _build(settings, const AuditLogScreen());

      default:
        return _build(settings, const SplashScreen());
    }
  }

  static MaterialPageRoute _build(RouteSettings settings, Widget page) =>
      MaterialPageRoute(settings: settings, builder: (_) => page);
}
