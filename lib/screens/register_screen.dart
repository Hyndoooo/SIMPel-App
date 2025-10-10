import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _register() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pendaftaran berhasil 🚀")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        // biar nggak overflow
        child: Padding(
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
                const SizedBox(height: 2),
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

                // Nama Lengkap
                const Text(
                  "Nama Lengkap*",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "Budiono Siregar",
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Nama tidak boleh kosong";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Kata Sandi
                const Text(
                  "Kata Sandi*",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Buat kata sandi",
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
                    if (value.length < 8) return "Password minimal 8 karakter";
                    return null;
                  },
                ),
                const SizedBox(height: 2),

                // Keterangan password
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Min. 8 Karakter"),
                    Text("Huruf Kecil"),
                    Text("Huruf Kapital"),
                    Text("Angka"),
                  ],
                ),
                const SizedBox(height: 20),

                // Konfirmasi Kata Sandi
                const Text(
                  "Konfirmasi Kata Sandi*",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: "Ketik ulang kata sandi",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Konfirmasi password wajib diisi";
                    if (value != _passwordController.text)
                      return "Password tidak sama";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Tombol Daftar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _register,
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
                            "Daftar",
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

                // Atau daftar dengan
                const Center(child: Text("Atau daftar dengan")),
                const SizedBox(height: 12),

                // Google Sign In
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey, width: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Image.asset(
                      "assets/images/google.png",
                      width: 24,
                      height: 24,
                    ),
                    label: const Text("Lanjutkan dengan Google"),
                  ),
                ),
                const SizedBox(height: 20),

                // Link sudah punya akun
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Sudah punya akun? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // balik ke login
                      },
                      child: const Text(
                        "Masuk",
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
