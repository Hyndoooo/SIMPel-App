import 'package:flutter/material.dart';
import '../beranda_screen.dart';
import '../notifikasi_screen.dart';
import '../obrolan/obrolan_screen.dart';
import '../akun/akun_screen.dart';
import 'modulajar_screen.dart';

class MatapelajaranScreen extends StatefulWidget {
  const MatapelajaranScreen({super.key});

  @override
  State<MatapelajaranScreen> createState() => _MatapelajaranScreenState();
}

class _MatapelajaranScreenState extends State<MatapelajaranScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BerandaScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NotifikasiScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ObrolanScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AkunScreen()),
        );
        break;
    }
  }

  final List<Map<String, dynamic>> mataPelajaran = [
    {
      "nama": "Bahasa Inggris",
      "icon": Icons.language,
      "color": Colors.amber.shade200,
    },
    {
      "nama": "Bahasa Indonesia",
      "icon": Icons.text_fields,
      "color": Colors.blue.shade200,
    },
    {
      "nama": "PJOK",
      "icon": Icons.sports_gymnastics,
      "color": Colors.red.shade200,
    },
    {"nama": "Prakarya", "icon": Icons.palette, "color": Colors.green.shade200},
    {
      "nama": "PAI dan BP",
      "icon": Icons.menu_book,
      "color": Colors.blue.shade100,
    },
    {
      "nama": "Seni Budaya",
      "icon": Icons.brush,
      "color": Colors.amber.shade100,
    },
    {"nama": "IPA", "icon": Icons.science, "color": Colors.red.shade100},
    {
      "nama": "Matematika",
      "icon": Icons.calculate,
      "color": Colors.blue.shade100,
    },
    {"nama": "TIK", "icon": Icons.computer, "color": Colors.blue.shade50},
    {"nama": "IPS", "icon": Icons.people, "color": Colors.green.shade100},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _bottomNavBar(),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Header
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      "Mata Pelajaran",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Grid Mata Pelajaran
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: GridView.builder(
                  itemCount: mataPelajaran.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // dua kolom
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (context, index) {
                    final item = mataPelajaran[index];
                    return GestureDetector(
                      onTap: () {
                        // ✅ Navigasi ke Modul Ajar sesuai mata pelajaran yang dipilih
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ModulajarScreen(mataPelajaran: item['nama']),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: item['color'],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item['icon'], size: 40, color: Colors.black87),
                            const SizedBox(height: 8),
                            Text(
                              item['nama'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Bottom Navigation Bar
  Widget _bottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: const Color(0xFF4A6CF7),
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_rounded),
          label: 'Notifikasi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline_rounded),
          label: 'Obrolan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Akun',
        ),
      ],
    );
  }
}
