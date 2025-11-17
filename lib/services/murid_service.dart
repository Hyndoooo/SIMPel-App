import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class MuridService {
  final String _ip = "10.118.148.27";
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

          // 🔹 Pastikan field kelas ada untuk Flutter
          if (murid['nama_kelas'] != null && murid['nama_kelas'] != '') {
            murid['kelas'] = murid['nama_kelas'];
          } else if (murid['kelas_id'] != null) {
            murid['kelas'] = 'ID: ${murid['kelas_id']}';
          } else {
            murid['kelas'] = '-';
          }

          if (murid['foto_profil'] != null && murid['foto_profil'] != '') {
            if (murid['foto_profil'].startsWith('http')) {
              // URL penuh dari Google, pakai langsung
              murid['foto_profil'] = murid['foto_profil'];
            } else {
              // Foto manual dari storage
              murid['foto_profil'] = '$storageUrl${murid['foto_profil']}';
            }
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
    String? kelasId,
  }) async {
    final url = Uri.parse('$baseUrl/update-murid');

    try {
      final body = {
        "email": email,
        "nama": nama,
        "jenis_kelamin": jenisKelamin,
        "nomer_whatsapp": nomerWhatsapp,
      };

      if (kelasId != null) {
        body["kelas_id"] = kelasId;
      }

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
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
    String? kelasId,
  }) async {
    final url = Uri.parse('$baseUrl/update-murid-foto');

    try {
      final request = http.MultipartRequest('POST', url);
      request.fields['email'] = email;
      request.fields['nama'] = nama;
      request.fields['jenis_kelamin'] = jenisKelamin;
      request.fields['nomer_whatsapp'] = nomerWhatsapp;

      if (kelasId != null) {
        request.fields['kelas_id'] = kelasId;
      }

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

  /// Ubah kata sandi murid dengan validasi kombinasi password
  Future<bool> changePassword({
    required String email,
    required String kataSandiLama,
    required String kataSandiBaru,
  }) async {
    // Validasi password baru
    final hasUppercase = kataSandiBaru.contains(RegExp(r'[A-Z]'));
    final hasLowercase = kataSandiBaru.contains(RegExp(r'[a-z]'));
    final hasDigit = kataSandiBaru.contains(RegExp(r'[0-9]'));
    final hasMinLength = kataSandiBaru.length >= 8;

    if (!(hasUppercase && hasLowercase && hasDigit && hasMinLength)) {
      print("❌ Password baru tidak memenuhi kriteria kombinasi");
      return false;
    }

    final url = Uri.parse('$baseUrl/murid/change-password');

    try {
      final body = {
        "email": email.trim(),
        "kata_sandi_lama": kataSandiLama.trim(),
        "kata_sandi_baru": kataSandiBaru.trim(),
      };

      print("📤 Request Change Password: $body");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("📡 POST: $url");
      print("📩 Response: ${response.statusCode} | ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        final data = jsonDecode(response.body);
        print("❌ Gagal ubah kata sandi: ${data['message']}");
        return false;
      }
    } catch (e) {
      print("⚠️ Error saat ubah kata sandi: $e");
      return false;
    }
  }

  /// Fungsi register murid (Manual)
  Future<bool> registerMurid({
    required String nis,
    required String nama,
    required String email,
    required String kelasId,
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
          "kelas_id": kelasId,
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

  // Login With Google
  Future<Map<String, dynamic>?> loginMuridGoogle({
    required String email,
  }) async {
    final url = Uri.parse('$baseUrl/murids/google-login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      print("📡 POST Google Login: $url");
      print("📩 Response: ${response.statusCode} | ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          return data["data"];
        }
      } else if (response.statusCode == 404) {
        // Email belum terdaftar
        return null;
      }

      return null;
    } catch (e) {
      print("⚠️ Error saat login Google: $e");
      return null;
    }
  }

  // Register With google Validasi NIS
  Future<Map<String, dynamic>> googleRegisterValidate({
    required String nama,
    required String email,
    String? foto,
    required String nis,
  }) async {
    final url = Uri.parse('$baseUrl/murids/google-register-validate');

    final response = await http.post(
      url,
      body: {'nama': nama, 'email': email, 'foto': foto ?? '', 'nis': nis},
    );

    return json.decode(response.body);
  }
}
