import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import '../services/murid_service.dart';

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

  // Firebase & Google
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Local auth
  final LocalAuthentication _localAuth = LocalAuthentication();

  // ===== CAROUSEL =====
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<String> carouselImages = [
    "assets/images/Bebas.png",
    "assets/images/Merenung.png",
    "assets/images/Mumet.png",
  ];

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  // ===========================
  // Shared Preferences
  // ===========================
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

  Future<void> clearUserDataButKeepFingerprintFlag() async {
    final prefs = await SharedPreferences.getInstance();
    final fp = prefs.getBool('fingerprint_enabled') ?? false;
    await prefs.clear();
    await prefs.setBool('fingerprint_enabled', fp);
  }

  Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ===========================
  // Google Sign In
  // ===========================
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

      if (user != null) await saveUserData(user);

      return user;
    } catch (e) {
      debugPrint("❌ Error Google Sign-In: $e");
      return null;
    }
  }

  Future<void> signOutAll() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    try {
      await _auth.signOut();
    } catch (_) {}
    await clearUserDataButKeepFingerprintFlag();
  }

  // ===========================
  // Session check
  // ===========================
  void checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isFingerprintEnabled = prefs.getBool('fingerprint_enabled') ?? false;

    if (isFingerprintEnabled) {
      final userData = await getUserData();

      if (userData != null) {
        final authenticated = await _localAuth.authenticate(
          localizedReason: 'Verifikasi identitas untuk login',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: false,
          ),
        );

        if (authenticated && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BerandaScreen()),
          );
          return;
        }
      }
    }

    setState(() => isLoading = false);
  }

  // ===========================
  // Google login handler
  // ===========================
  void handleGoogleSignIn() async {
    final user = await signInWithGoogle();

    if (user != null) {
      final muridData = await MuridService().loginMuridGoogle(
        email: user.email ?? '',
      );

      if (muridData != null) {
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
            content: Text("Email belum terdaftar, silakan registrasi dulu"),
          ),
        );
        await signOutAll();
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login gagal atau dibatalkan")),
      );
    }
  }

  // ===========================
  // Fingerprint login
  // ===========================
  Future<void> handleFingerprintLogin() async {
    try {
      bool canCheck = await _localAuth.canCheckBiometrics;
      bool isSupported = await _localAuth.isDeviceSupported();

      if (!canCheck || !isSupported) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Perangkat tidak mendukung fingerprint"),
          ),
        );
        return;
      }

      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Verifikasi identitas untuk login',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: false,
        ),
      );

      final userData = await getUserData();

      if (userData != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BerandaScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tidak ada akun tersimpan, login manual dulu"),
          ),
        );
      }
    } catch (e) {
      print("❌ Fingerprint error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Autentikasi fingerprint gagal")),
      );
    }
  }

  // ===========================
  // UI COMPONENTS
  // ===========================
  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: handleGoogleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          side: const BorderSide(color: Colors.grey, width: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        icon: Image.asset("assets/images/google.png", width: 24),
        label: const Text(
          "Lanjutkan dengan Google",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildBrimoLoginButton() {
    return Expanded(
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A6CF7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: const [
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Masuk",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFingerprintIconButton() {
    return SizedBox(
      height: 50,
      width: 55,
      child: ElevatedButton(
        onPressed: handleFingerprintLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.black87,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Icon(Icons.fingerprint, size: 26),
      ),
    );
  }

  // ===========================
  // MAIN BUILD
  // ===========================
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          // ===== BLUE BACKGROUND WITH DECORATION =====
          CustomPaint(painter: BlueBackgroundPainter(), child: Container()),

          SafeArea(
            child: Column(
              children: [
                // ===== ATAS (Gambar Carousel) =====
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // CAROUSEL
                        SizedBox(
                          height: 240,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: carouselImages.length,
                            onPageChanged: (index) {
                              setState(() => _currentIndex = index);
                            },
                            itemBuilder: (_, index) {
                              return Image.asset(
                                carouselImages[index],
                                fit: BoxFit.contain,
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 32),

                        Text(
                          "Sekolah jadi lebih mudah\ndengan SIMPel",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // DOT INDICATOR
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: carouselImages.asMap().entries.map((entry) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _currentIndex == entry.key ? 18 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: _currentIndex == entry.key
                                    ? Colors.white
                                    : Colors.white54,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // ===== BAGIAN BAWAH PUTIH =====
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                      child: Column(
                        children: [
                          // Garis kecil
                          Container(
                            width: 60,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),

                          const SizedBox(height: 28),

                          _buildGoogleButton(),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              _buildBrimoLoginButton(),
                              const SizedBox(width: 12),
                              _buildFingerprintIconButton(),
                            ],
                          ),

                          const Spacer(),

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

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BlueBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF4A6CF7);

    // ===== BASE BLUE BACKGROUND =====
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // ===== DEKORASI LINGKARAN BESAR TRANSPARAN =====
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.1),
      90,
      circlePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.05),
      70,
      circlePaint,
    );

    // ===== GELOMBANG PUTIH TIPIS =====
    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    path.moveTo(0, size.height * 0.25);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.20,
      size.width * 0.5,
      size.height * 0.28,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.35,
      size.width,
      size.height * 0.30,
    );

    canvas.drawPath(path, wavePaint);

    // ===== GELOMBANG KEDUA =====
    final wavePaint2 = Paint()
      ..color = Colors.white.withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.32);
    path2.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.40,
      size.width * 0.6,
      size.height * 0.33,
    );
    path2.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.25,
      size.width,
      size.height * 0.36,
    );

    canvas.drawPath(path2, wavePaint2);

    // ===== BULATAN KECIL-KCIL =====
    final smallDot = Paint()..color = Colors.white.withOpacity(0.2);

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.18),
      6,
      smallDot,
    );
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.22),
      5,
      smallDot,
    );
    canvas.drawCircle(
      Offset(size.width * 0.55, size.height * 0.12),
      4,
      smallDot,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
