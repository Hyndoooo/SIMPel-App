import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginService {
  final String baseUrl = "http://10.183.53.27:8000/api";

  /// Fungsi login murid
  Future<bool> loginMurid({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/login-murid");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "kata_sandi": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["success"] == true;
      } else {
        print("Login gagal: ${response.statusCode} | ${response.body}");
        return false;
      }
    } catch (e) {
      print("Login error: $e");
      return false;
    }
  }

  /// Fungsi ambil detail murid berdasarkan email
  Future<Map<String, dynamic>?> getMuridByEmail(String email) async {
    final encodedEmail = Uri.encodeComponent(email);
    final url = Uri.parse('$baseUrl/murid/email/$encodedEmail');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Struktur respons bisa bervariasi
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data') && data['data'] != null) {
            return data['data'];
          } else if (data.containsKey('murid')) {
            return data['murid'];
          } else if (data.containsKey('success') && data['success'] == true) {
            return data['murid'] ?? data;
          } else {
            return data;
          }
        }

        print("⚠️ Format data murid kosong/tidak sesuai");
        return null;
      } else {
        print(
          "❌ Gagal ambil data murid: ${response.statusCode} - ${response.body}",
        );
        return null;
      }
    } catch (e) {
      print("⚠️ Error koneksi: $e");
      return null;
    }
  }
}
