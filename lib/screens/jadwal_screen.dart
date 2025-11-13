import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/jadwal_service.dart';
import 'beranda_screen.dart';

class JadwalScreen extends StatefulWidget {
  final int kelasId;
  const JadwalScreen({Key? key, required this.kelasId}) : super(key: key);

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};
  List<dynamic> _jadwalHariIni = [];

  final JadwalService _jadwalService = JadwalService();

  @override
  void initState() {
    super.initState();
    _loadAllJadwal();
  }

  Future<void> _loadAllJadwal() async {
    try {
      final data = await _jadwalService.getJadwalByKelas(widget.kelasId);
      final Map<DateTime, List<dynamic>> eventMap = {};

      for (var j in data) {
        DateTime tanggal = DateTime.parse(j['tanggal']);
        DateTime key = DateTime(tanggal.year, tanggal.month, tanggal.day);
        if (eventMap[key] == null) eventMap[key] = [];
        eventMap[key]!.add(j);
      }

      setState(() {
        _events = eventMap;
        _selectedDay = DateTime.now();
        _jadwalHariIni = _events[_selectedDay!] ?? [];
      });

      // 🔹 Pastikan UI sudah build sebelum show bottom sheet
      if (_jadwalHariIni.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) {
            _showBottomSheet(_selectedDay!, _jadwalHariIni);
          }
        });
      }
    } catch (e) {
      print("Gagal load jadwal: $e");
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _showBottomSheet(DateTime day, List<dynamic> jadwalList) {
    if (!mounted) return;

    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Jadwal ${_getFormattedDate(day)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
              ),
              for (var j in jadwalList)
                Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.book, color: Color(0xFF4A6CF7)),
                    title: Text(
                      j['mata_pelajaran'] ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      "${j['jam_mulai']} - ${j['jam_selesai']}\n${j['guru']}",
                    ),
                    isThreeLine: true,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleSpacing: 8,
        title: const Text(
          "Jadwal",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BerandaScreen()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            // 🔹 Header bulan + tahun + panah kanan/kiri
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${_getNamaBulan(_focusedDay.month)} ${_focusedDay.year}",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 28),
                      onPressed: () {
                        setState(() {
                          _focusedDay = DateTime(
                            _focusedDay.year,
                            _focusedDay.month - 1,
                          );
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 28),
                      onPressed: () {
                        setState(() {
                          _focusedDay = DateTime(
                            _focusedDay.year,
                            _focusedDay.month + 1,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 🔹 Kalender
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                final jadwal = _getEventsForDay(selectedDay);
                if (jadwal.isNotEmpty) {
                  _showBottomSheet(selectedDay, jadwal);
                }
              },
              eventLoader: _getEventsForDay,
              headerVisible: false,
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.black87),
                weekendStyle: TextStyle(color: Colors.black87),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: const Color(0xFF4A6CF7).withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFF4A6CF7),
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                markerMargin: const EdgeInsets.only(top: 3, right: 3),
                outsideDaysVisible: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    String dayName = days[date.weekday - 1];
    String monthName = months[date.month - 1];
    return "$dayName, ${date.day} $monthName";
  }

  String _getNamaBulan(int bulan) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[bulan - 1];
  }
}
