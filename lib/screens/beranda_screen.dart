import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/murid_service.dart';
import '../services/jadwal_service.dart';
import '../services/auth_service.dart'; // untuk Google SignOut
import 'jadwal_screen.dart';
import 'notifikasi_screen.dart';
import 'obrolan/obrolan_screen.dart';
import 'akun/akun_screen.dart';
import 'nilai/periodekelas_screen.dart';
import 'kehadiran/kehadiran_screen.dart';
import 'belajar/kemajuanbelajar_screen.dart';
import 'modul/periode_screen.dart';
import 'spp/spp_screen.dart';
import 'welcome_screen.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  int _currentIndex = 0;
  String nama = '';
  String kelas = '';
  int? kelasId;
  List<dynamic> jadwalHariIni = [];
  bool isLoadingJadwal = true;

  // ================== UNTUK SEARCH BAR ==================
  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  final List<Map<String, dynamic>> menuItems = [
    {"icon": Icons.assignment, "title": "Nilai"},
    {"icon": Icons.check_circle, "title": "Kehadiran"},
    {"icon": Icons.rocket, "title": "Kemajuan Belajar"},
    {"icon": Icons.menu_book, "title": "Modul Pelajaran"},
    {"icon": Icons.payment, "title": "SPP"},
  ];

  @override
  void initState() {
    super.initState();
    _loadMuridData();
  }

  // Future<void> _loadMuridData() async {
  //   final prefs = await SharedPreferences.getInstance();

  //   // Ambil data langsung dari SharedPreferences yang disimpan saat registrasi Google
  //   final namaPrefs = prefs.getString('nama') ?? 'Pengguna';
  //   final kelasPrefs = prefs.getString('kelas') ?? '-';
  //   final fotoPrefs = prefs.getString('foto_profil') ?? '';

  //   setState(() {
  //     nama = namaPrefs;
  //     kelas = kelasPrefs;
  //     // Bisa simpan foto ke variabel jika mau ditampilkan
  //     // fotoProfil = fotoPrefs;
  //   });

  //   // Opsional: tetap bisa panggil API untuk data lebih lengkap
  //   final email = prefs.getString('email');
  //   if (email != null) {
  //     try {
  //       final muridService = MuridService();
  //       final murid = await muridService.getMuridByEmail(email);

  //       if (murid != null) {
  //         setState(() {
  //           nama = murid['nama'] ?? namaPrefs;
  //           kelasId = murid['kelas_id'];
  //           if (murid['kelas'] is Map) {
  //             kelas = murid['kelas']['nama_kelas'] ?? kelasPrefs;
  //           }
  //         });

  //         if (kelasId != null) {
  //           await _loadJadwalHariIni(kelasId!);
  //         }
  //       }
  //     } catch (e) {
  //       print("❌ Error saat load murid: $e");
  //     }
  //   }

  //   setState(() {
  //     isLoadingJadwal = false;
  //   });
  // }

  Future<void> _loadMuridData() async {
    final prefs = await SharedPreferences.getInstance();

    // Ambil data langsung dari SharedPreferences
    final namaPrefs = prefs.getString('nama') ?? 'Pengguna';
    final kelasPrefs = prefs.getString('kelas') ?? '-';
    final fotoPrefs = prefs.getString('foto_profil') ?? '';

    setState(() {
      nama = namaPrefs;
      kelas = kelasPrefs;
    });

    final email = prefs.getString('email');
    if (email != null) {
      try {
        final muridService = MuridService();
        final murid = await muridService.getMuridByEmail(email);

        if (murid != null) {
          setState(() {
            nama = murid['nama'] ?? namaPrefs;
            kelasId = murid['kelas_id'];

            // ==== PERBAIKAN BAGIAN KELAS ====
            if (murid.containsKey('kelas')) {
              if (murid['kelas'] is Map) {
                kelas = murid['kelas']['nama_kelas'] ?? kelasPrefs;
              } else if (murid['kelas'] is String) {
                kelas = murid['kelas'];
              } else {
                // fallback misal integer ID atau null
                kelas = kelasPrefs;
              }
            } else {
              kelas = kelasPrefs;
            }
          });

          if (kelasId != null) {
            await _loadJadwalHariIni(kelasId!);
          }
        }
      } catch (e) {
        print("❌ Error saat load murid: $e");
        setState(() {
          kelas = kelasPrefs; // fallback
        });
      }
    }

    setState(() {
      isLoadingJadwal = false;
    });
  }

  Future<void> _loadJadwalHariIni(int kelasId) async {
    try {
      final jadwalService = JadwalService();
      final now = DateTime.now();
      final tanggal = "${now.year}-${now.month}-${now.day}";
      final result = await jadwalService.getJadwalByDate(kelasId, tanggal);

      setState(() {
        jadwalHariIni = result;
        isLoadingJadwal = false;
      });
    } catch (e) {
      print("❌ Gagal ambil jadwal: $e");
      setState(() {
        jadwalHariIni = [];
        isLoadingJadwal = false;
      });
    }
  }

  String _formatTanggal() {
    final now = DateTime.now();
    const bulan = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return "${now.day} ${bulan[now.month]} ${now.year}";
  }

  @override
  Widget build(BuildContext context) {
    final filteredMenu = menuItems
        .where(
          (item) =>
              item['title']!.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ================= Header =================
              Container(
                margin: const EdgeInsets.all(16),
                width: double.infinity,
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A6CF7), Color(0xFF6D89F7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Halo,",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nama.isNotEmpty ? "$nama – $kelas" : "Memuat data...",
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const Spacer(),
                    Container(
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26.withOpacity(0.15),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: "Cari menu...",
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ================= Jadwal Hari Ini =================
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8ECFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Jadwal Hari Ini\n${_formatTanggal()}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (kelasId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      JadwalScreen(kelasId: kelasId!),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Data kelas belum tersedia."),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: const Text("Lihat Jadwal"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A6CF7),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (isLoadingJadwal)
                      const Center(child: CircularProgressIndicator())
                    else if (jadwalHariIni.isEmpty)
                      const Text(
                        "Tidak ada jadwal hari ini",
                        style: TextStyle(fontSize: 14),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: jadwalHariIni
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Text(
                                  "${item['mata_pelajaran']}\n${item['jam_mulai']} - ${item['jam_selesai']}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ================= MySchools =================
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "MySchools",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Gunakan menu ini untuk melihat informasi sekolah anda.",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ================= Menu Grid =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: filteredMenu
                      .map(
                        (item) => _buildMenuItem(
                          item['icon'],
                          item['title'],
                          context,
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  BottomNavigationBar _bottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF4A6CF7),
      unselectedItemColor: Colors.grey,
      currentIndex: _currentIndex,
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotifikasiScreen()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ObrolanScreen()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AkunScreen()),
          );
        } else {
          setState(() => _currentIndex = index);
        }
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
    );
  }

  Widget _buildMenuItem(IconData icon, String title, BuildContext context) {
    return InkWell(
      onTap: () {
        if (title == "Nilai") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PeriodekelasScreen()),
          );
        } else if (title == "Kehadiran") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const KehadiranScreen()),
          );
        } else if (title == "Kemajuan Belajar") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const KemajuanbelajarScreen()),
          );
        } else if (title == "Modul Pelajaran") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PeriodeScreen()),
          );
        } else if (title == "SPP") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SppScreen()),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF4A6CF7), size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
