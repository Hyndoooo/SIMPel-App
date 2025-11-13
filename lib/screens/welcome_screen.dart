import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/murid_service.dart'; // pastikan file ini ada

import 'login_screen.dart';
import 'register_screen.dart';
import 'beranda_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isLoading = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  // ======================================================
  // SharedPreferences
  // ======================================================
  Future<void> saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nama', user.displayName ?? '');
    await prefs.setString('email', user.email ?? '');
    await prefs.setString('foto', user.photoURL ?? '');
  }

  Future<Map<String, String>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    if (email == null) return null;
    return {
      'nama': prefs.getString('nama') ?? '',
      'email': email,
      'foto': prefs.getString('foto') ?? '',
    };
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ======================================================
  // Firebase Google Sign-In
  // ======================================================
  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        await saveUserData(user);
        await _saveUserToDatabase(user); // Simpan ke database Laravel
      }

      return user;
    } catch (e) {
      print("❌ Error Google Sign-In: $e");
      return null;
    }
  }

  Future<void> _saveUserToDatabase(User user) async {
    try {
      final muridService = MuridService();

      // 🔹 Gunakan fungsi baru
      final muridData = await muridService.registerOrGetMuridGoogle(
        nama: user.displayName ?? '',
        email: user.email ?? '',
        foto: user.photoURL ?? '',
      );

      if (muridData != null) {
        print("✅ User Google tersimpan / sudah ada di DB");
      } else {
        print("❌ Gagal simpan atau ambil data user dari DB");
      }
    } catch (e) {
      print("❌ Error saat simpan user: $e");
    }
  }

  // ======================================================
  // Logout
  // ======================================================
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    await clearUserData();
  }

  // ======================================================
  // Cek session login
  // ======================================================
  void checkSession() async {
    final userData = await getUserData();
    if (userData != null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BerandaScreen()),
      );
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void handleGoogleSignIn() async {
    final user = await signInWithGoogle();

    if (user != null) {
      // 🔹 Ambil atau register murid di Laravel
      final muridData = await MuridService().registerOrGetMuridGoogle(
        nama: user.displayName ?? '',
        email: user.email ?? '',
        foto: user.photoURL ?? '',
      );

      if (muridData != null) {
        // Simpan data ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('nama', muridData['nama'] ?? '');
        await prefs.setString('email', muridData['email'] ?? '');
        await prefs.setString('foto', muridData['foto_profil'] ?? '');

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BerandaScreen()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal ambil data murid setelah register"),
          ),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login gagal atau dibatalkan")),
      );
    }
  }

  // ======================================================
  // Build UI
  // ======================================================
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  margin: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            "assets/images/SIMPel.png",
                            width: 170,
                            height: 170,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Title
                const Text(
                  "WELCOME TO\nSIMPel",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 33, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 100),

                // Tombol Google Sign-In
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: handleGoogleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Colors.grey, width: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    icon: Image.asset(
                      "assets/images/google.png",
                      width: 24,
                      height: 24,
                    ),
                    label: const Text(
                      "Lanjutkan dengan Google",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tombol Masuk Manual
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A6CF7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Masuk",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum punya akun? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Daftar",
                        style: TextStyle(
                          color: Color(0xFF4A6CF7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
