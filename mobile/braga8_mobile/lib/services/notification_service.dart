import 'package:http/http.dart' as http;

class NotificationService {
  static const String baseUrl = "your_api_url_here";

  Future<void> markAsRead(int id) async {
    final response = await http.patch(Uri.parse('$baseUrl/notifications/$id/read'));
    if (response.statusCode != 200) throw Exception('Failed to update');
  }

  Future<void> deleteNotification(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/notifications/$id'));
    if (response.statusCode != 200) throw Exception('Failed to delete');
  }
}