import 'package:flutter/material.dart';
import '../beranda_screen.dart';
import '../notifikasi_screen.dart';
import '../obrolan/obrolan_screen.dart';
import '../akun/akun_screen.dart';

class DaftarnilaiScreen extends StatefulWidget {
  final String kelas;

  const DaftarnilaiScreen({super.key, required this.kelas});

  @override
  State<DaftarnilaiScreen> createState() => _DaftarnilaiScreenState();
}

class _DaftarnilaiScreenState extends State<DaftarnilaiScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  String? selectedPeriode;

  final List<String> periodeList = [
    '2025 Ganjil',
    '2025 Genap',
    '2026 Ganjil',
    '2026 Genap',
    '2027 Ganjil',
    '2027 Genap',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
                  Expanded(
                    child: Text(
                      "Periode Nilai - ${widget.kelas}",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pilih Periode",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedPeriode,
                        hint: const Text(
                          "Pilih Periode",
                          style: TextStyle(color: Colors.black54),
                        ),
                        items: periodeList.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPeriode = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Tab Bar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                indicatorWeight: 2,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: "Tugas"),
                  Tab(text: "Ulangan Harian"),
                  Tab(text: "UTS"),
                  Tab(text: "UAS"),
                ],
              ),
            ),

            // 🔹 Isi TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _dataKosong("Tugas"),
                  _dataKosong("Ulangan Harian"),
                  _dataKosong("UTS"),
                  _uasTabView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dataKosong(String jenis) {
    return Center(
      child: Text(
        selectedPeriode == null
            ? "Pilih periode terlebih dahulu untuk melihat data $jenis"
            : "Belum ada data $jenis untuk ${widget.kelas} ($selectedPeriode)",
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15, color: Colors.black54),
      ),
    );
  }

  // 🔹 Tabel nilai UAS (Nilai rata tengah)
  Widget _uasTabView() {
    final List<Map<String, dynamic>> nilaiList = [
      {"mapel": "Bahasa Inggris", "nilai": 6},
      {"mapel": "Bahasa Indonesia", "nilai": 6},
      {"mapel": "Pendidikan Agama dan BP", "nilai": 6},
      {"mapel": "Ilmu Pengetahuan Sosial", "nilai": 6},
      {"mapel": "Ilmu Pengetahuan Alam", "nilai": 7},
      {"mapel": "Matematika", "nilai": 6},
      {"mapel": "Pendidikan Pancasila", "nilai": 6},
      {"mapel": "PJOK", "nilai": 7},
      {"mapel": "TIK", "nilai": 6},
      {"mapel": "Seni Budaya", "nilai": 8},
      {"mapel": "Prakarya", "nilai": 6},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 14,
          ),
          dataTextStyle: const TextStyle(fontSize: 14, color: Colors.black87),
          columns: const [
            DataColumn(label: Text("Mata Pelajaran")),
            DataColumn(numeric: true, label: Center(child: Text("Nilai"))),
          ],
          rows: nilaiList
              .map(
                (item) => DataRow(
                  cells: [
                    DataCell(Text(item["mapel"])),
                    DataCell(
                      Center(
                        child: Text(
                          item["nilai"].toString(),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

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
