import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class MuridService {
  // 🧠 Cukup ubah IP di sini aja kalau ganti server
  final String _ip = "10.183.53.27";
  late final String baseUrl = "http://$_ip:8000/api";
  late final String storageUrl = "http://$_ip:8000/storage/";

  /// Ambil data murid berdasarkan email
  Future<Map<String, dynamic>?> getMuridByEmail(String email) async {
    final encodedEmail = Uri.encodeComponent(email);
    final url = Uri.parse('$baseUrl/murid/email/$encodedEmail');

    try {
      final response = await http.get(url);

      print("📡 GET: $url");
      print("📩 Response: ${response.statusCode} | ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final murid = Map<String, dynamic>.from(data['data']);

          // Jika ada foto_profil, buat URL penuh otomatis
          if (murid['foto_profil'] != null && murid['foto_profil'] != '') {
            murid['foto_profil'] = '$storageUrl${murid['foto_profil']}';
          } else {
            murid['foto_profil'] = null;
          }

          return murid;
        }
      }
      print("❌ Gagal ambil data murid: ${response.statusCode}");
      return null;
    } catch (e) {
      print("⚠️ Error koneksi: $e");
      return null;
    }
  }

  /// Update profil murid tanpa foto
  Future<bool> updateMurid({
    required String email,
    required String nama,
    required String jenisKelamin,
    required String nomerWhatsapp,
  }) async {
    final url = Uri.parse('$baseUrl/update-murid');

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "nama": nama,
          "jenis_kelamin": jenisKelamin,
          "nomer_whatsapp": nomerWhatsapp,
        }),
      );

      print("📡 PUT: $url");
      print("📩 Response: ${response.statusCode} | ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data["success"] == true;
      }
      return false;
    } catch (e) {
      print("⚠️ Error saat update murid: $e");
      return false;
    }
  }

  /// Update profil murid beserta foto
  Future<bool> updateMuridWithFoto({
    required String email,
    required String nama,
    required String jenisKelamin,
    required String nomerWhatsapp,
    required File fotoProfil,
  }) async {
    final url = Uri.parse('$baseUrl/update-murid-foto');

    try {
      final request = http.MultipartRequest('POST', url);
      request.fields['email'] = email;
      request.fields['nama'] = nama;
      request.fields['jenis_kelamin'] = jenisKelamin;
      request.fields['nomer_whatsapp'] = nomerWhatsapp;

      // Tambahkan file foto
      request.files.add(
        await http.MultipartFile.fromPath('foto_profil', fotoProfil.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("📡 POST Multipart: $url");
      print("📩 Response: ${response.statusCode} | ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print("⚠️ Error saat update dengan foto: $e");
      return false;
    }
  }

  /// Fungsi register murid
  Future<bool> registerMurid({
    required String nis,
    required String nama,
    required String email,
    required String kelas,
    required String jenisKelamin,
    required String kataSandi,
    required String nomerWhatsapp,
  }) async {
    final url = Uri.parse('$baseUrl/register-murid');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nis": nis,
          "nama": nama,
          "email": email,
          "kelas": kelas,
          "jenis_kelamin": jenisKelamin,
          "kata_sandi": kataSandi,
          "nomer_whatsapp": nomerWhatsapp,
        }),
      );

      print("📡 POST: $url");
      print("📩 Response: ${response.statusCode} | ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data["success"] == true;
      }
      return false;
    } catch (e) {
      print("⚠️ Error saat register murid: $e");
      return false;
    }
  }
}
