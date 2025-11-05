import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                        padding: const EdgeInsets.all(13), // tebal border
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

                // Google Sign In button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Aksi login Google di sini
                    },
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

                // Tombol Masuk
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
