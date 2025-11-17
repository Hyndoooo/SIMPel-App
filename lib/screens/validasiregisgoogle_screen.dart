import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/murid_service.dart';
import 'beranda_screen.dart';

class ValidasiRegisGoogleScreen extends StatefulWidget {
  final String nama;
  final String email;
  final String? foto;

  const ValidasiRegisGoogleScreen({
    required this.nama,
    required this.email,
    required this.foto,
    super.key,
  });

  @override
  State<ValidasiRegisGoogleScreen> createState() =>
      _ValidasiRegisGoogleScreenState();
}

class _ValidasiRegisGoogleScreenState extends State<ValidasiRegisGoogleScreen> {
  final nisController = TextEditingController();
  bool isLoading = false;

  // ==========================
  // Fungsi submit NIS
  // ==========================
  Future<void> submitNis() async {
    setState(() => isLoading = true);

    Map<String, dynamic> response;
    try {
      response = await MuridService().googleRegisterValidate(
        nama: widget.nama,
        email: widget.email,
        foto: widget.foto,
        nis: nisController.text.trim(),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan, coba lagi")),
      );
      return;
    }

    setState(() => isLoading = false);

    if (response['success'] == true) {
      final muridData = response['data'];

      // Simpan ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('murid_id', muridData['id']);
      await prefs.setString('nama', muridData['nama']);
      await prefs.setString('email', muridData['email']);
      await prefs.setString('foto_profil', muridData['foto_profil'] ?? '');
      await prefs.setString(
        'kelas',
        muridData['kelas'] != null
            ? muridData['kelas']['nama_kelas'] ?? '-'
            : '-',
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Akun berhasil dibuat!")));

      // Delay supaya SnackBar terlihat
      await Future.delayed(const Duration(seconds: 1));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BerandaScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Terjadi kesalahan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Validasi NIS"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            children: [
              // ==========================
              // Foto Profil / Avatar
              // ==========================
              if (widget.foto != null)
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(widget.foto!),
                )
              else
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
              const SizedBox(height: 16),

              // ==========================
              // Salam / Title
              // ==========================
              Text(
                "Halo, ${widget.nama}!",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Masukkan NIS Anda untuk melanjutkan.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // ==========================
              // Row input NIS + Tombol Icon Panah
              // ==========================
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Input NIS
                      Expanded(
                        child: TextField(
                          controller: nisController,
                          decoration: const InputDecoration(
                            hintText: "Masukkan NIS",
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.confirmation_number),
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Tombol Icon Panah
                      InkWell(
                        onTap: isLoading ? null : submitNis,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.black,
                                  size: 24,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ==========================
              // Info tambahan
              // ==========================
              const Text(
                "Pastikan NIS yang Anda masukkan sesuai dengan data sekolah.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
