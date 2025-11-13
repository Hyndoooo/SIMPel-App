import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  final String _ip = "10.118.148.27";
  late final String baseUrl = "http://$_ip:8000/api";

  /// Ambil semua notifikasi berdasarkan email murid
  Future<List<dynamic>> fetchNotifications(String email) async {
    final encodedEmail = Uri.encodeComponent(email);
    final url = Uri.parse('$baseUrl/murid/$encodedEmail/notifications');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // ✅ Perbaikan: support int (1/0) atau bool (true/false)
        if ((data['success'] == 1 || data['success'] == true) &&
            data['data'] != null) {
          return data['data'] as List<dynamic>;
        }
        return [];
      } else {
        print("❌ Gagal ambil notifikasi: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("⚠️ Error koneksi fetchNotifications: $e");
      return [];
    }
  }

  /// Tandai notifikasi sebagai sudah dibaca
  Future<bool> markAsRead(int notificationId) async {
    final url = Uri.parse('$baseUrl/notification/$notificationId/read');

    try {
      final response = await http.put(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // ✅ Perbaikan: support int (1/0) atau bool (true/false)
        return data['success'] == 1 || data['success'] == true;
      }
      return false;
    } catch (e) {
      print("⚠️ Error koneksi markAsRead: $e");
      return false;
    }
  }
}
