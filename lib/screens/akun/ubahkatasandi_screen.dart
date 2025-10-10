import 'package:flutter/material.dart';

class UbahkatasandiScreen extends StatefulWidget {
  const UbahkatasandiScreen({super.key});

  @override
  State<UbahkatasandiScreen> createState() => _UbahkatasandiScreen();
}

class _UbahkatasandiScreen extends State<UbahkatasandiScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mengubah Kata Sandi',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kata Sandi Lama
              const Text(
                'Kata Sandi Lama *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: _oldPasswordController,
                obscureText: _obscureOld,
                decoration: InputDecoration(
                  hintText: 'Masukan Kata Sandi Lama',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureOld ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureOld = !_obscureOld;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Masukkan kata sandi lama';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Kata Sandi Baru
              const Text(
                'Kata Sandi Baru *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  hintText: 'Masukan Kata Sandi Baru',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNew = !_obscureNew;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Masukkan kata sandi baru';
                  if (value.length < 8) return 'Minimal 8 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Kriteria Kata Sandi
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // top-aligned
                    children: const [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.check, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Flexible(child: Text('Min. 8 Karakter')),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.check, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Flexible(child: Text('Huruf Kecil')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.check, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Flexible(child: Text('Huruf Kapital')),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.check, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Flexible(child: Text('Angka')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Konfirmasi Kata Sandi
              const Text(
                'Konfirmasi Kata Sandi *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  hintText: 'Masukan Lagi Kata Sandi Baru',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirm = !_obscureConfirm;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Masukkan konfirmasi kata sandi';
                  if (value != _newPasswordController.text)
                    return 'Kata sandi tidak sama';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Implementasi simpan kata sandi
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kata sandi berhasil diubah!'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A6CF7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // teks jadi putih
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
