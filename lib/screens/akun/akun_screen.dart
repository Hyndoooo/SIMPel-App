import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool isFingerprintEnabled = false;

  @override
  void initState() {
    super.initState();
    // Panggil async functions via Future.microtask
    Future.microtask(() {
      _loadMuridData();
      _loadFingerprintPref();
    });
  }

  // =========================
  // Load data murid dari API
  // =========================
  Future<void> _loadMuridData() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email');

    if (email == null) {
      setState(() => _isLoading = false);
      return;
    }

    final muridData = await _muridService.getMuridByEmail(email!);

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

  // =========================
  // Load preference fingerprint
  // =========================
  Future<void> _loadFingerprintPref() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('fingerprint_enabled') ?? false;
    setState(() {
      isFingerprintEnabled = enabled;
    });
  }

  // =========================
  // Toggle fingerprint
  // =========================
  Future<void> _toggleFingerprint(bool value) async {
    // Cek perangkat mendukung fingerprint
    final canCheck = await _localAuth.canCheckBiometrics;
    final isSupported = await _localAuth.isDeviceSupported();
    if (!canCheck || !isSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perangkat tidak mendukung fingerprint")),
      );
      return;
    }

    setState(() => isFingerprintEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fingerprint_enabled', value);
  }

  // =========================
  // Navigasi bottom bar
  // =========================
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

  // =========================
  // Logout
  // =========================
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();

    // Simpan status fingerprint sebelum hapus data akun
    final fingerprintEnabled = prefs.getBool('fingerprint_enabled') ?? false;

    // Hapus hanya data akun, jangan hapus fingerprint
    await prefs.remove('email');
    await prefs.remove('nama');
    await prefs.remove('foto');

    // Kembalikan fingerprint_enabled jika sebelumnya tersimpan
    await prefs.setBool('fingerprint_enabled', fingerprintEnabled);

    await _authService.signOut();

    // Update UI switch
    setState(() => isFingerprintEnabled = fingerprintEnabled);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  // =========================
  // Build UI
  // =========================
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
                // Info Akun
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

                // Switch Login Fingerprint
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Login dengan Sidik Jari"),
                      Switch(
                        value: isFingerprintEnabled,
                        onChanged: _toggleFingerprint,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Ubah Kata Sandi
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

                // Logout
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
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 20),
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
                              InkWell(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _logout();
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
