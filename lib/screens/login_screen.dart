import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/murid_service.dart';
import '../services/login_service.dart';

import 'register_screen.dart';
import 'beranda_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // Firebase & Google Sign-In
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ===================== SharedPreferences =====================
  Future<void> saveUserData(Map<String, dynamic> muridData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nama', muridData['nama'] ?? '');
    await prefs.setString('email', muridData['email'] ?? '');
    await prefs.setString('nis', muridData['nis'] ?? '');
    await prefs.setString('kelas', muridData['kelas'] ?? '');
    await prefs.setString('jenis_kelamin', muridData['jenis_kelamin'] ?? '');
    await prefs.setString('telepon', muridData['nomer_whatsapp'] ?? '');
    await prefs.setString('foto', muridData['foto_profil'] ?? '');
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ===================== Login Manual =====================
  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sedang memproses login...")),
      );

      final service = LoginService();
      final success = await service.loginMurid(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (success) {
        final muridData = await service.getMuridByEmail(
          _emailController.text.trim(),
        );

        if (muridData != null) await saveUserData(muridData);

        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BerandaScreen()),
        );
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login gagal ❌, periksa email dan kata sandi."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // ===================== Login Google =====================
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
        await _saveUserToDatabase(user);
      }

      return user;
    } catch (e) {
      print("❌ Error Google Sign-In: $e");
      return null;
    }
  }

  Future<void> _saveUserToDatabase(User user) async {
    try {
      final muridData = await MuridService().registerOrGetMuridGoogle(
        nama: user.displayName ?? '',
        email: user.email ?? '',
        foto: user.photoURL ?? '',
      );

      if (muridData != null) await saveUserData(muridData);
    } catch (e) {
      print("❌ Error simpan user: $e");
    }
  }

  void handleGoogleSignIn() async {
    final user = await signInWithGoogle();

    if (user != null) {
      final muridData = await MuridService().registerOrGetMuridGoogle(
        nama: user.displayName ?? '',
        email: user.email ?? '',
        foto: user.photoURL ?? '',
      );

      if (muridData != null) {
        await saveUserData(muridData);
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
        const SnackBar(content: Text("Login Google gagal atau dibatalkan")),
      );
    }
  }

  // ===================== Build UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Masuk"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email
              const Text(
                "Email*",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "youremail@gmail.com",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Email tidak boleh kosong";
                  if (!value.contains('@')) return "Format email tidak valid";
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Password
              const Text(
                "Kata Sandi*",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: "Masukkan kata sandi",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Password tidak boleh kosong";
                  if (value.length < 6) return "Password minimal 6 karakter";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Lupa password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Lupa kata sandi?",
                    style: TextStyle(color: Color(0xFF4A6CF7)),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Tombol Masuk Manual
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A6CF7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Masuk",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
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
              const SizedBox(height: 16),

              // Tombol Google Sign-In
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: handleGoogleSignIn,
                  icon: Image.asset(
                    'assets/images/google.png',
                    width: 24,
                    height: 24,
                  ),
                  label: const Text(
                    "Login dengan Google",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Colors.grey, width: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Link ke Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum punya akun? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
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
    );
  }
}
