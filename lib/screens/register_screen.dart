import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/murid_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nisController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _waController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // visibility
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // indikator validasi password
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigit = false;
  bool _hasMinLength = false;

  // kelas dropdown
  List<Map<String, dynamic>> _kelasList = [];
  String? _selectedKelasId; // akan menyimpan id (sebagai String)

  // loading
  bool _isLoadingKelas = true;
  bool _isSubmitting = false;

  // service
  final MuridService _service = MuridService();

  @override
  void initState() {
    super.initState();
    _fetchKelas();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _nisController.dispose();
    _genderController.dispose();
    _waController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Ambil daftar kelas dari API GET /api/kelas
  Future<void> _fetchKelas() async {
    setState(() => _isLoadingKelas = true);
    try {
      final url = Uri.parse('${_service.baseUrl}/kelas');
      final resp = await http.get(url);

      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        if (decoded is Map && decoded['data'] is List) {
          final List data = decoded['data'];
          _kelasList = data.map<Map<String, dynamic>>((e) {
            return {
              'id': e['id'].toString(),
              'nama_kelas': e['nama_kelas'] ?? e['nama'] ?? 'Kelas',
            };
          }).toList();
        } else {
          _kelasList = [];
        }
      } else {
        // gagal ambil; kosongkan list
        _kelasList = [];
        debugPrint('Gagal ambil kelas: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      _kelasList = [];
      debugPrint('Error fetch kelas: $e');
    } finally {
      setState(() => _isLoadingKelas = false);
    }
  }

  // fungsi validasi password kombinasi
  bool _isPasswordValid(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasMinLength = password.length >= 8;
    return hasUppercase && hasLowercase && hasDigit && hasMinLength;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedKelasId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan pilih kelas terlebih dahulu")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await _service.registerMurid(
      nis: _nisController.text.trim(),
      nama: _nameController.text.trim(),
      email: _emailController.text.trim(),
      kelasId: _selectedKelasId!, // <-- kirim kelas_id sesuai service baru
      jenisKelamin: _genderController.text.trim(),
      kataSandi: _passwordController.text,
      nomerWhatsapp: _waController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pendaftaran berhasil ✅"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Pendaftaran gagal ❌, periksa koneksi atau data yang dimasukkan.",
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Widget indikator kriteria password (dua kolom) sama seperti desain lama
  Widget _buildPasswordCriteria() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kolom kiri
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check,
                    size: 16,
                    color: _hasMinLength ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  const Flexible(child: Text('Min. 8 Karakter')),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.check,
                    size: 16,
                    color: _hasLowercase ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  const Flexible(child: Text('Huruf Kecil')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        // Kolom kanan
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check,
                    size: 16,
                    color: _hasUppercase ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  const Flexible(child: Text('Huruf Kapital')),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.check,
                    size: 16,
                    color: _hasDigit ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  const Flexible(child: Text('Angka')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Build seluruh form — tampilan dipertahankan sesuai kode lama
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
                  validator: (value) => value == null || value.isEmpty
                      ? "Nama tidak boleh kosong"
                      : null,
                ),
                const SizedBox(height: 20),

                // NIS
                const Text(
                  "NIS*",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                TextFormField(
                  controller: _nisController,
                  decoration: InputDecoration(
                    hintText: "Masukkan NIS",
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || value.isEmpty ? "NIS wajib diisi" : null,
                ),
                const SizedBox(height: 20),

                // Kelas (DIUBAH MENJADI DROPDOWN)
                const Text(
                  "Kelas*",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                _isLoadingKelas
                    ? Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    : DropdownButtonFormField<String>(
                        value: _selectedKelasId,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.class_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        hint: const Text("Pilih Kelas"),
                        items: _kelasList.map((k) {
                          return DropdownMenuItem<String>(
                            value: k['id'].toString(),
                            child: Text(k['nama_kelas'].toString()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedKelasId = val;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? "Kelas wajib diisi"
                            : null,
                      ),
                const SizedBox(height: 20),

                // Jenis Kelamin
                const Text(
                  "Jenis Kelamin*",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.wc_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  value: null,
                  hint: const Text("Pilih Jenis Kelamin"),
                  items: const [
                    DropdownMenuItem(
                      value: "Laki-laki",
                      child: Text("Laki-laki"),
                    ),
                    DropdownMenuItem(
                      value: "Perempuan",
                      child: Text("Perempuan"),
                    ),
                  ],
                  onChanged: (value) {
                    _genderController.text = value ?? '';
                  },
                  validator: (value) =>
                      value == null ? "Pilih jenis kelamin" : null,
                ),
                const SizedBox(height: 20),

                // No. WA
                const Text(
                  "No. WhatsApp*",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                TextFormField(
                  controller: _waController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "Contoh: 081234567890",
                    prefixIcon: const Icon(Icons.phone_android_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? "Nomor WA wajib diisi"
                      : null,
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
                  onChanged: (value) {
                    setState(() {
                      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
                      _hasLowercase = value.contains(RegExp(r'[a-z]'));
                      _hasDigit = value.contains(RegExp(r'[0-9]'));
                      _hasMinLength = value.length >= 8;
                    });
                  },
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
                    if (!_isPasswordValid(value)) {
                      return "Password harus ada huruf besar, huruf kecil, angka, dan min. 8 karakter";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 8),
                _buildPasswordCriteria(),
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
                    onPressed: _isSubmitting ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A6CF7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Daftar",
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Sudah punya akun? "),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
