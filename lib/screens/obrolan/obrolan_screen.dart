import 'package:flutter/material.dart';
import '../beranda_screen.dart';
import '../notifikasi_screen.dart';
import '../akun/akun_screen.dart';
import 'kontak_screen.dart';
import 'chatroom_screen.dart';

class ObrolanScreen extends StatefulWidget {
  const ObrolanScreen({super.key});

  @override
  State<ObrolanScreen> createState() => _ObrolanScreenState();
}

class _ObrolanScreenState extends State<ObrolanScreen> {
  int _currentIndex = 2; // Obrolan aktif

  void _onNavBarTap(int index) {
    if (index == _currentIndex) return; // Sudah di screen ini
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BerandaScreen()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NotifikasiScreen()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AkunScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Obrolan', style: TextStyle(color: Colors.black)),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage('assets/images/krisna.jpg'),
            ),
            title: const Text(
              'Bapak Rudy Tabuti',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Setelah mata pelajaran harap...'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '09:20',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '1',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            onTap: () {
              // Navigasi ke ChatroomScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatroomScreen(
                    nama: "Bapak Rudy Tabuti",
                    avatarColor: Colors.grey,
                  ),
                ),
              );
            },
          ),
          // Tambahin list obrolan lain di sini
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke KontakScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KontakScreen()),
          );
        },
        backgroundColor: const Color(0xFF4A6CF7),
        child: const Icon(Icons.contacts), // ganti biar sesuai: ikon kontak
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4A6CF7),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Obrolan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}
