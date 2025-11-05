import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../beranda_screen.dart';
import '../notifikasi_screen.dart';
import '../obrolan/obrolan_screen.dart';
import '../akun/akun_screen.dart';
import 'package:simpel/services/murid_service.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  int _currentIndex = 3;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nisController = TextEditingController();
  final TextEditingController _kelasController = TextEditingController();
  final TextEditingController _noWaController = TextEditingController();

  String jenisKelamin = 'Laki-laki';
  final List<String> jenisKelaminList = ['Laki-laki', 'Perempuan'];

  final MuridService _muridService = MuridService();
  File? _fotoProfil; // Foto lokal baru
  String? _fotoProfilUrl; // Foto lama dari server

  @override
  void initState() {
    super.initState();
    _loadMuridData();
  }

  Future<void> _loadMuridData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';

    if (email.isNotEmpty) {
      final data = await _muridService.getMuridByEmail(email);

      if (data != null) {
        setState(() {
          _namaController.text = data['nama'] ?? '-';
          _emailController.text = data['email'] ?? '-';
          _nisController.text = data['nis'] ?? '-';
          _kelasController.text = data['kelas'] ?? '-';
          _noWaController.text = data['nomer_whatsapp'] ?? '-';
          jenisKelamin = data['jenis_kelamin'] ?? 'Laki-laki';
          _fotoProfilUrl = data['foto_profil']; // ambil URL dari server
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _fotoProfil = File(pickedFile.path);
      });
    }
  }

  Future<void> _simpanData() async {
    final nama = _namaController.text.trim();
    final nomerWhatsapp = _noWaController.text.trim();
    final email = _emailController.text.trim();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nama', nama);
    await prefs.setString('jenis_kelamin', jenisKelamin);
    await prefs.setString('nomerWhatsapp', nomerWhatsapp);

    bool success = false;

    if (_fotoProfil != null) {
      // Update data + upload foto
      success = await _muridService.updateMuridWithFoto(
        email: email,
        nama: nama,
        jenisKelamin: jenisKelamin,
        nomerWhatsapp: nomerWhatsapp,
        fotoProfil: _fotoProfil!,
      );
    } else {
      // Update tanpa foto
      success = await _muridService.updateMurid(
        email: email,
        nama: nama,
        jenisKelamin: jenisKelamin,
        nomerWhatsapp: nomerWhatsapp,
      );
    }

    if (success) {
      // 🔄 Ambil ulang data terbaru dari server
      final updatedData = await _muridService.getMuridByEmail(email);

      if (updatedData != null) {
        setState(() {
          _fotoProfilUrl = updatedData['foto_profil'];
          _fotoProfil = null;
        });

        // Simpan juga ke SharedPreferences
        await prefs.setString('foto_profil', updatedData['foto_profil'] ?? '');
      }

      // ✅ Langsung kembali ke halaman AkunScreen tanpa notifikasi
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AkunScreen()),
        );
      }
    } else {
      // ❌ Hanya tampilkan notifikasi kalau gagal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan data ❌'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Edit Profil', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AkunScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blue.shade200,
                    backgroundImage: _fotoProfil != null
                        ? FileImage(_fotoProfil!)
                        : (_fotoProfilUrl != null
                              ? NetworkImage(_fotoProfilUrl!) as ImageProvider
                              : null),
                    child: _fotoProfil == null && _fotoProfilUrl == null
                        ? const Icon(
                            Icons.school,
                            size: 60,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade400,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Email
            TextFormField(
              controller: _emailController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Nama
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // NIS
            TextFormField(
              controller: _nisController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'NIS',
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Kelas
            TextFormField(
              controller: _kelasController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Kelas',
                prefixIcon: Icon(Icons.class_),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Jenis Kelamin
            DropdownButtonFormField<String>(
              value: jenisKelamin,
              decoration: const InputDecoration(
                labelText: 'Jenis Kelamin',
                prefixIcon: Icon(Icons.transgender),
                border: OutlineInputBorder(),
              ),
              items: jenisKelaminList.map((value) {
                return DropdownMenuItem(value: value, child: Text(value));
              }).toList(),
              onChanged: (val) {
                setState(() {
                  jenisKelamin = val ?? 'Laki-laki';
                });
              },
            ),
            const SizedBox(height: 16),

            // Nomor WA
            TextFormField(
              controller: _noWaController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor WhatsApp',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _simpanData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade200,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BerandaScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const NotifikasiScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ObrolanScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AkunScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Obrolan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }
}
