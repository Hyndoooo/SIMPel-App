import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/notification_service.dart';
import 'obrolan/obrolan_screen.dart';
import 'beranda_screen.dart';
import 'akun/akun_screen.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  bool parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  Future<void> _loadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email != null) {
      final fetched = await NotificationService().fetchNotifications(email);
      setState(() {
        // Pastikan is_read selalu bool
        notifications = fetched.map((notif) {
          notif['is_read'] = parseBool(notif['is_read']);
          return notif;
        }).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        notifications = [];
        isLoading = false;
      });
    }
  }

  Widget _buildNotificationItem(dynamic notif) {
    DateTime? createdAt;
    try {
      createdAt = notif['created_at'] != null
          ? DateTime.parse(notif['created_at'])
          : null;
    } catch (e) {
      createdAt = null;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: notif['is_read'] ? Colors.grey[100] : Colors.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          notif['is_read'] ? Icons.notifications_none : Icons.notifications,
          color: notif['is_read'] ? Colors.grey : Colors.blue,
          size: 30,
        ),
        title: Text(
          notif['title'] ?? "Tidak ada judul",
          style: TextStyle(
            fontWeight: notif['is_read'] ? FontWeight.normal : FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notif['message'] ?? "",
              style: TextStyle(
                fontSize: 14,
                color: notif['is_read'] ? Colors.grey[700] : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            if (createdAt != null)
              Text(
                timeago.format(createdAt, locale: 'id'),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        trailing: notif['is_read']
            ? null
            : IconButton(
                icon: const Icon(Icons.check, color: Colors.blue),
                onPressed: () async {
                  bool success = await NotificationService().markAsRead(
                    notif['id'],
                  );
                  if (success) {
                    setState(() {
                      notif['is_read'] = true;
                    });
                  }
                },
              ),
      ),
    );
  }

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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : notifications.isEmpty
            ? Center(
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
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return _buildNotificationItem(notifications[index]);
                },
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        selectedItemColor: const Color(0xFF4A6CF7),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BerandaScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ObrolanScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AkunScreen()),
            );
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
      ),
    );
  }
}
