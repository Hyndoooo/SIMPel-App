import 'package:flutter/material.dart';
import '../beranda_screen.dart';
import '../notifikasi_screen.dart';
import '../akun/akun_screen.dart';
import 'chatroom_screen.dart';

class KontakScreen extends StatelessWidget {
  const KontakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Daftar Kontak",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView(
        children: [
          _KontakItem(
            nama: "Bapak Rudy Tabuti",
            avatarColor: Colors.grey,
            icon: Icons.person,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChatroomScreen(
                    nama: "Bapak Rudy Tabuti",
                    avatarColor: Colors.grey,
                  ),
                ),
              );
            },
          ),
          _KontakItem(
            nama: "Bapak Vincent Sius",
            avatarColor: Colors.deepPurple,
            icon: Icons.person,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChatroomScreen(
                    nama: "Bapak Vincent Sius",
                    avatarColor: Colors.deepPurple,
                  ),
                ),
              );
            },
          ),
          _KontakItem(
            nama: "Ibu Salsa",
            avatarColor: Colors.pinkAccent,
            icon: Icons.person,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChatroomScreen(
                    nama: "Ibu Salsa",
                    avatarColor: Colors.pinkAccent,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // posisi "Obrolan" aktif
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const BerandaScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
            );
          } else if (index == 2) {
            // posisi Obrolan (KontakScreen) -> tetap di sini
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AkunScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Beranda",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: "Notifikasi",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Obrolan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Akun",
          ),
        ],
      ),
    );
  }
}

class _KontakItem extends StatelessWidget {
  final String nama;
  final Color avatarColor;
  final IconData icon;
  final VoidCallback onTap;

  const _KontakItem({
    required this.nama,
    required this.avatarColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: avatarColor,
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(nama),
      onTap: onTap,
    );
  }
}
