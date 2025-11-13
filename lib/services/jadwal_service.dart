import 'dart:convert';
import 'package:http/http.dart' as http;

class JadwalService {
  final String baseUrl =
      'http://10.118.148.27:8000/api'; // Ganti IP sesuai server kamu

  // Ambil jadwal berdasarkan kelas
  Future<List<dynamic>> getJadwalByKelas(int kelasId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/jadwal?kelas_id=$kelasId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map && data.containsKey('data')) {
        return data['data']; // Laravel biasanya return {data: [...]}
      }
      return data; // Jika langsung list
    } else {
      throw Exception('Gagal memuat jadwal');
    }
  }

  // Ambil jadwal berdasarkan kelas dan tanggal
  Future<List<dynamic>> getJadwalByDate(int kelasId, String tanggal) async {
    final response = await http.get(
      Uri.parse('$baseUrl/jadwal/tanggal?kelas_id=$kelasId&tanggal=$tanggal'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map && data.containsKey('data')) {
        return data['data'];
      }
      return data;
    } else {
      throw Exception('Gagal memuat jadwal berdasarkan tanggal');
    }
  }
}
