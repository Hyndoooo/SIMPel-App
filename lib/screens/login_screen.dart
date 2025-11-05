import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_screen.dart';
import 'beranda_screen.dart';
import '../services/login_service.dart';

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

  // === Fungsi Login ===
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
        // ✅ Ambil detail murid dari API
        final muridData = await service.getMuridByEmail(
          _emailController.text.trim(),
        );

        final prefs = await SharedPreferences.getInstance();
        if (muridData != null) {
          await prefs.setString('email', muridData['email'] ?? '');
          await prefs.setString('nama', muridData['nama'] ?? '');
          await prefs.setString('nis', muridData['nis'] ?? '');
          await prefs.setString('kelas', muridData['kelas'] ?? '');
          await prefs.setString(
            'jenis_kelamin',
            muridData['jenis_kelamin'] ?? '',
          );
          await prefs.setString('telepon', muridData['nomer_whatsapp'] ?? '');
        }

        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login berhasil ✅"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BerandaScreen()),
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
              // === Email ===
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
                  if (value == null || value.isEmpty) {
                    return "Email tidak boleh kosong";
                  }
                  if (!value.contains('@')) {
                    return "Format email tidak valid";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // === Kata Sandi ===
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
                  if (value == null || value.isEmpty) {
                    return "Password tidak boleh kosong";
                  }
                  if (value.length < 6) {
                    return "Password minimal 6 karakter";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // === Lupa Kata Sandi ===
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

              // === Tombol Masuk ===
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
              const SizedBox(height: 20),

              // === Link ke Daftar ===
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
    );
  }
}
