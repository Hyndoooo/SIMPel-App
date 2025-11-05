import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/murid_service.dart';
import '../beranda_screen.dart';
import '../notifikasi_screen.dart';
import '../obrolan/obrolan_screen.dart';
import '../welcome_screen.dart';
import 'edit_screen.dart';
import 'ubahkatasandi_screen.dart';

class AkunScreen extends StatefulWidget {
  const AkunScreen({super.key});

  @override
  State<AkunScreen> createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  int _currentIndex = 3;
  bool _isLoading = true;

  String nama = "-";
  String nis = "-";
  String kelas = "-";
  String? fotoProfilUrl;

  final MuridService _muridService = MuridService();

  @override
  void initState() {
    super.initState();
    _loadMuridData();
  }

  Future<void> _loadMuridData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    print("📧 Email tersimpan: $email");

    if (email == null) {
      setState(() => _isLoading = false);
      return;
    }

    final muridData = await _muridService.getMuridByEmail(email);
    print("🧩 Data dari API: $muridData");

    if (muridData != null) {
      setState(() {
        nama = muridData['nama'] ?? '-';
        nis = muridData['nis'] ?? '-';
        kelas = muridData['kelas'] ?? '-';
        fotoProfilUrl = muridData['foto_profil']; // langsung pakai dari service
      });
    }
    setState(() => _isLoading = false);
  }

  void _onNavBarTap(int index) {
    if (index == _currentIndex) return;
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
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8ECFF),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFF4A6CF7),
                        backgroundImage: fotoProfilUrl != null
                            ? NetworkImage(fotoProfilUrl!)
                            : null,
                        child: fotoProfilUrl == null
                            ? const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 30,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(nis),
                            const SizedBox(height: 2),
                            Text("Kelas - $kelas"),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditScreen(),
                                ),
                              ).then((_) {
                                _loadMuridData(); // refresh setelah edit
                              });
                            },
                            icon: const Icon(Icons.edit, color: Colors.black),
                          ),
                          const Text("Edit", style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text("Ubah Kata Sandi"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UbahkatasandiScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Keluar"),
                  onTap: _logout,
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF4A6CF7),
        unselectedItemColor: Colors.grey,
        onTap: _onNavBarTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Beranda",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: "Notifikasi",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Obrolan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Akun",
          ),
        ],
      ),
    );
  }
}
