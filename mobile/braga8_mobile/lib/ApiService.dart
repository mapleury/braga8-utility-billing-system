import 'dart:convert';
import 'dart:io';
import 'package:braga8_mobile/data/models/audit_log_model.dart';
import 'package:braga8_mobile/data/models/tenant_model.dart';
import 'package:braga8_mobile/data/models/notification_model.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

int unreadNotificationsCount = 0;

class ApiService {
  // --- SINGLETON ARCHITECTURE ---
  // This ensures there is only ONE instance of ApiService in the whole app.
  static final ApiService _instance = ApiService._internal();
  factory ApiService({String? token}) {
    if (token != null) _instance.token = token;
    return _instance;
  }
  ApiService._internal();
  // ------------------------------

  String? token;
  Map<String, dynamic>? currentUser;

  static const String _baseUrl = 'http://localhost:8000/api';

  final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: const Duration(
              seconds: 15,
            ), // Increased to prevent timeouts
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        )
        ..interceptors.add(
          LogInterceptor(responseBody: true, requestBody: true, error: true),
        );

  /// Private helper for Auth Headers
  /// Logic: Uses provided string, or falls back to the saved class token.
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
      if (response.data != null && response.data['user'] != null) {
        currentUser = response.data['user'];
        // SESSION PERSISTENCE: This token is now available for all other calls
        token = response.data['token'];
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

  // --- TENANT & PROFILE LOGIC ---

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

  // --- METER LOGIC ---

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

  // --- DAFTAR UNIT LOGIC (AUTOMATED) ---

  Future<List<Tenant>> fetchUnitsSummary() async {
    try {
      // No more passing tokens manually. It uses the Singleton token.
      final response = await dio.get('/units/summary', options: _authOptions());
      final List data = response.data;
      return data.map((t) => Tenant.fromJson(t)).toList();
    } on DioException catch (e) {
      print('STATUS: ${e.response?.statusCode}');
      print('DATA: ${e.response?.data}');
      throw Exception('Failed to load units: ${e.message}');
    } catch (e) {
      print('PARSING ERROR: $e');
      throw Exception('Data mapping failed');
    }
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied)
        return Future.error('Location permissions are denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<AuditLogResponse> fetchLogs(int page) async {
    try {
      final response = await dio.get(
        '/audit-logs',
        queryParameters: {'page': page},
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        // Dio otomatis parse JSON ke Map, jadi tidak perlu json.decode lagi
        return AuditLogResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load audit logs');
      }
    } on DioException catch (e) {
      print('Fetch Logs Error: ${e.response?.data}');
      throw Exception('Network error while fetching logs');
    }
  }

  // --- METER READING LOGIC ---

  Future<bool> updateReading({
    required int readingId,
    required String newValue,
    String? description,
    // Jika lo mau update foto juga, kirim file-nya di sini pakai Multipart
  }) async {
    try {
      final response = await dio.put(
        '/readings/$readingId', // Sesuaikan endpoint API Laravel lo
        data: {'reading_value': newValue, 'description': description},
        options: _authOptions(),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update Reading Error: $e');
      return false;
    }
  }

  Future<bool> submitMeterReading(
    Map<String, dynamic> data,
    File? image,
  ) async {
    try {
      FormData formData = FormData.fromMap(data);

      if (image != null) {
        formData.files.add(
          MapEntry(
            'photo', // Sesuaikan key file di Laravel
            await MultipartFile.fromFile(
              image.path,
              filename: 'meter_reading.jpg',
            ),
          ),
        );
      }

      final response = await dio.post(
        '/readings', // Sesuaikan endpoint lo
        data: formData,
        options: _authOptions(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
