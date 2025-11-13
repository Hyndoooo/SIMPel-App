import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/murid_service.dart';
import '../../services/auth_service.dart';
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
  String? email;

  final MuridService _muridService = MuridService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadMuridData();
  }

  Future<void> _loadMuridData() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email');

    print("📧 Email tersimpan: $email");

    if (email == null) {
      setState(() => _isLoading = false);
      return;
    }

    final muridData = await _muridService.getMuridByEmail(email!);
    print("🧩 Data dari API: $muridData");

    if (muridData != null) {
      setState(() {
        nama = muridData['nama'] ?? '-';
        nis = muridData['nis'] ?? '-';
        kelas = muridData['kelas'] ?? '-';
        fotoProfilUrl = muridData['foto_profil'];
      });
    }
    setState(() => _isLoading = false);
  }

  void _onNavBarTap(int index) {
    if (index == _currentIndex) return;
    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = const BerandaScreen();
        break;
      case 1:
        nextPage = const NotifikasiScreen();
        break;
      case 2:
        nextPage = const ObrolanScreen();
        break;
      default:
        return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextPage),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _authService.signOut();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
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
                        radius: 35,
                        backgroundColor: const Color(0xFF4A6CF7),
                        backgroundImage: fotoProfilUrl != null
                            ? NetworkImage(fotoProfilUrl!)
                            : null,
                        child: fotoProfilUrl == null
                            ? const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 35,
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
                            Text("NIS: $nis"),
                            const SizedBox(height: 2),
                            Text("Kelas: $kelas"),
                            const SizedBox(height: 4),
                            if (email != null)
                              Text(
                                email!,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
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
                                  builder: (_) => const EditScreen(),
                                ),
                              ).then((_) => _loadMuridData());
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
                        builder: (_) => const UbahkatasandiScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Keluar"),
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) {
                        return Dialog(
                          backgroundColor: Colors.white,
                          insetPadding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              20,
                            ), // ✅ sudut bulat
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 20),

                              // ✅ Teks utama mirip Instagram
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  "Logout dari akun Anda?",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                    height: 1.3,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),
                              const Divider(height: 1, thickness: 0.8),

                              // 🔴 Tombol Logout
                              InkWell(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                                onTap: () {
                                  Navigator.pop(context); // tutup dialog
                                  _logout(); // panggil fungsi logout
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Center(
                                    child: Text(
                                      "Logout",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const Divider(height: 1, thickness: 0.8),

                              // ⚫ Tombol Batalkan
                              InkWell(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                                onTap: () => Navigator.pop(context),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Center(
                                    child: Text(
                                      "Batalkan",
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
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
