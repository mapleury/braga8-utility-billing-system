import 'dart:convert';
import 'package:braga8_mobile/data/models/audit_log_model.dart';
import 'package:braga8_mobile/data/models/meter_reading_model.dart';
import 'package:braga8_mobile/data/models/tenant_model.dart';
import 'package:braga8_mobile/data/models/notification_model.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as _dio;

int unreadNotificationsCount = 0;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService({String? token}) {
    if (token != null) _instance.token = token;
    return _instance;
  }
  ApiService._internal();

  String? token;
  Map<String, dynamic>? currentUser;

  static const String _baseUrl = 'https://bunkbed-deem-spew.ngrok-free.dev/api';

  final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'ngrok-skip-browser-warning': 'true',
            },
          ),
        )
        ..interceptors.add(
          LogInterceptor(responseBody: true, requestBody: true, error: true),
        );

  Options _authOptions([String? providedToken]) {
    final effectiveToken = (providedToken ?? token ?? "").trim();
    return Options(headers: {'Authorization': 'Bearer $effectiveToken'});
  }

  // --- AUTHENTICATION ---

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );
      // Inside login method:
      if (response.data != null && response.data['token'] != null) {
        this.token = response.data['token'];
        currentUser = response.data['user'];
      }
      return response.data;
    } on DioException catch (e) {
      print('Login Failed: ${e.response?.data}');
      return null;
    }
  }

  Future<void> logout(String providedToken) async {
    try {
      await dio.post('/logout', options: _authOptions(providedToken));
      currentUser = null;
      token = null;
    } catch (e) {
      print('Logout Error: $e');
    }
  }

  // --- TENANT & PROFILE ---

  Future<List<dynamic>> getTenants(String providedToken) async {
    try {
      final response = await dio.get(
        '/tenants',
        options: _authOptions(providedToken),
      );
      return response.data is List
          ? response.data
          : (response.data['data'] ?? []);
    } catch (e) {
      print('Fetch Tenants Error: $e');
      return [];
    }
  }

  Future<bool> updateProfile(
    Map<String, dynamic> data,
    String providedToken,
  ) async {
    try {
      final response = await dio.post(
        '/profile/update',
        data: data,
        options: _authOptions(providedToken),
      );
      if (response.statusCode == 200) {
        currentUser = response.data['user'];
        return true;
      }
      return false;
    } on DioException catch (e) {
      print("Update Profile Error: ${e.response?.data}");
      return false;
    }
  }

  // --- NOTIFICATIONS ---

  Future<List<NotificationModel>> getNotifications(String providedToken) async {
    try {
      final response = await dio.get(
        '/notifications',
        options: _authOptions(providedToken),
      );
      final List rawData = response.data['data']['data'] ?? [];
      return rawData.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      print('Fetch Notifications Error: $e');
      return [];
    }
  }

  Future<bool> markAsRead(int id, String providedToken) async {
    try {
      final response = await dio.patch(
        '/notifications/$id/read',
        options: _authOptions(providedToken),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Mark Read Error: $e');
      return false;
    }
  }

  Future<bool> deleteNotification(int id, String providedToken) async {
    try {
      final response = await dio.delete(
        '/notifications/$id',
        options: _authOptions(providedToken),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Delete Notification Error: $e');
      return false;
    }
  }

  // --- METER STATS ---

  Future<Map<String, dynamic>> getMonthlyStats(String providedToken) async {
    try {
      final response = await dio.get(
        '/meter-progress',
        options: _authOptions(providedToken),
      );
      return response.data;
    } on DioException catch (e) {
      print('Fetch Stats Error: ${e.response?.data}');
      return {'total': 0, 'readings': 0, 'percentage': 0};
    }
  }

  // --- UNITS ---

  Future<List<Tenant>> fetchUnitsSummary() async {
    try {
      final response = await dio.get('/units/summary', options: _authOptions());
      print("RAW DATA FROM SERVER: ${response.data}"); // <--- LIHAT DI CONSOLE
      final List data = response.data;
      return data.map((t) => Tenant.fromJson(t)).toList();
    } catch (e) {
      throw Exception('Failed to load units');
    }
  }

  // --- LOCATION ---

  Future<Position> determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  // --- AUDIT LOGS ---

  Future<AuditLogResponse> fetchLogs(int page) async {
    try {
      final response = await dio.get(
        '/audit-logs',
        queryParameters: {'page': page},
        options: _authOptions(),
      );
      if (response.statusCode == 200)
        return AuditLogResponse.fromJson(response.data);
      throw Exception('Failed to load audit logs');
    } on DioException catch (e) {
      print('Fetch Logs Error: ${e.response?.data}');
      throw Exception('Network error while fetching logs');
    }
  }

  // --- METER READINGS ---

  Future<bool> updateReading({
    required int readingId,
    required String newValue,
    String? description,
  }) async {
    try {
      final response = await dio.put(
        '/readings/$readingId',
        data: {'reading_value': newValue, 'description': description},
        options: _authOptions(),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update Reading Error: $e');
      return false;
    }
  }

  /// Kirim data meter reading ke Laravel.
  ///
  /// STRATEGI: selalu pakai JSON + Base64 untuk foto.
  /// Tidak ada lagi kIsWeb branch — Base64 works di web DAN mobile.
  /// Laravel decode Base64 via injectBase64Photo() di controller.
  Future<bool> submitMeterReading(
    Map<String, dynamic> data,
    XFile? image, {
    bool isEdit = false,
    int? readingId,
    required int unitId,
    required int meterId, // Gunakan parameter ini
  }) async {
    try {
      final String path = isEdit ? '/readings/$readingId' : '/readings';
      final Map<String, dynamic> payload = Map.from(data);

      // KUNCI PERBAIKAN:
      payload['meter_id'] = meterId; // ID dari tabel utility_meters
      payload['unit_id'] = unitId; // ID dari tabel units

      if (isEdit) payload['_method'] = 'PUT';

      if (image != null) {
        final bytes = await image.readAsBytes();
        final ext = image.name.split('.').last.toLowerCase();
        final mime = (ext == 'png') ? 'image/png' : 'image/jpeg';
        payload['photo_base64'] = 'data:$mime;base64,${base64Encode(bytes)}';
      }

      final response = await dio.post(
        path,
        data: payload,
        options: _authOptions(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      debugPrint('DETAIL ERROR: ${jsonEncode(e.response?.data)}');
      final serverMessage = e.response?.data?['message'];
      if (serverMessage != null) throw Exception(serverMessage);
      return false;
    }
  }

  Future<List<MeterReadingHistory>> fetchReadingHistory(int unitId) async {
    try {
      final response = await dio.get(
        '/units/$unitId/readings',
        options: _authOptions(),
      );
      final List data = response.data as List;
      return data.map((e) => MeterReadingHistory.fromJson(e)).toList();
    } on DioException catch (e) {
      debugPrint('Fetch History Error: ${e.response?.data}');
      throw Exception('Failed to load reading history');
    }
  }

  Future<Object?> getBillingSummary(String token) async {}

  Future<bool> clearAllNotifications(String providedToken) async {
    try {
      final response = await dio.delete(
        '/notifications',
        options: _authOptions(providedToken),
      );
      print('Clear All Status: ${response.statusCode}');
      print('Clear All Response: ${response.data}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Clear All Error Status: ${e.response?.statusCode}');
      print('Clear All Error Body: ${e.response?.data}');
      return false;
    }
  }

  Future<bool> markAllAsRead(String providedToken) async {
    try {
      final response = await dio.patch(
        '/notifications/read-all',
        options: _authOptions(providedToken),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Mark All Read Error: $e');
      return false;
    }
  }

  void setCurrentUser(Map<String, dynamic> user) {
    currentUser = user;
  }
}
