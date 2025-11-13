import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/murid_service.dart';

class UbahkatasandiScreen extends StatefulWidget {
  const UbahkatasandiScreen({super.key});

  @override
  State<UbahkatasandiScreen> createState() => _UbahkatasandiScreenState();
}

class _UbahkatasandiScreenState extends State<UbahkatasandiScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // indikator kriteria password
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigit = false;
  bool _hasMinLength = false;

  bool _isSubmitting = false;
  final MuridService _service = MuridService();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<String?> _getEmailUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  void _checkPassword(String value) {
    setState(() {
      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
      _hasLowercase = value.contains(RegExp(r'[a-z]'));
      _hasDigit = value.contains(RegExp(r'[0-9]'));
      _hasMinLength = value.length >= 8;
    });
  }

  Future<void> _submitChangePassword() async {
    final email = await _getEmailUser();
    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User tidak ditemukan!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final success = await _service.changePassword(
      email: email,
      kataSandiLama: _oldPasswordController.text,
      kataSandiBaru: _newPasswordController.text,
    );

    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Kata sandi berhasil diubah ✅'
              : 'Gagal mengubah kata sandi ❌',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) Navigator.pop(context);
  }

  Widget _buildPasswordCriteria() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
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
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Row(
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
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
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
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Row(
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
            ),
          ],
        ),
      ],
    );
  }

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
                    onPressed: () => setState(() => _obscureOld = !_obscureOld),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Masukkan kata sandi lama'
                    : null,
              ),
              const SizedBox(height: 16),

              const Text(
                'Kata Sandi Baru *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                onChanged: _checkPassword,
                decoration: InputDecoration(
                  hintText: 'Masukan Kata Sandi Baru',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Masukkan kata sandi baru';
                  if (!(_hasUppercase &&
                      _hasLowercase &&
                      _hasDigit &&
                      _hasMinLength))
                    return 'Password harus huruf besar, kecil, angka, dan min 8 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              _buildPasswordCriteria(),
              const SizedBox(height: 16),

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
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
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

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitChangePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A6CF7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Simpan',
                          style: TextStyle(fontSize: 16, color: Colors.white),
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
