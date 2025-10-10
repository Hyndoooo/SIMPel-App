import 'package:flutter/material.dart';
import 'obrolan/obrolan_screen.dart';
import 'beranda_screen.dart';
import 'akun/akun_screen.dart';

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Notifikasi", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/notifikasi.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Belum Ada\nNotifikasi!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // Notifikasi aktif
        selectedItemColor: const Color(0xFF4A6CF7),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            // Navigasi ke Beranda
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BerandaScreen()),
            );
          } else if (index == 2) {
            // Navigasi ke Obrolan
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ObrolanScreen()),
            );
          } else if (index == 3) {
            // Navigasi ke Akun
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AkunScreen()),
            );
          }
          // index 1 (Notifikasi) tetap di sini
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notifikasi",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Obrolan"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
        ],
      ),
    );
  }
}
