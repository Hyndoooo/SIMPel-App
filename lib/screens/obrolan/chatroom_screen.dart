import 'package:flutter/material.dart';
import '../beranda_screen.dart';
import '../notifikasi_screen.dart';
import '../akun/akun_screen.dart';

class ChatroomScreen extends StatelessWidget {
  final String nama;
  final Color avatarColor;

  const ChatroomScreen({
    super.key,
    required this.nama,
    required this.avatarColor,
  });

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
        titleSpacing: 0, // biar avatar nempel ke tombol back
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: avatarColor,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              nama,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                Align(
                  alignment: Alignment.centerLeft,
                  child: _ChatBubble(
                    text:
                        "Setelah mata pelajaran harap menemui bapak di ruang BK",
                    time: "09:20",
                    isSender: false,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: _ChatBubble(
                    text: "Siap bapak terimakasih atas infonya",
                    time: "09:30",
                    isSender: true,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Ketik Pesan ...",
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: () {
                      // aksi kirim pesan
                    },
                  ),
                ),
              ],
            ),
          ),
          BottomNavigationBar(
            currentIndex: 2, // posisi default di Obrolan
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BerandaScreen(),
                  ),
                );
              } else if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotifikasiScreen(),
                  ),
                );
              } else if (index == 2) {
                // Obrolan → sudah di sini, jadi tidak perlu pindah
              } else if (index == 3) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AkunScreen()),
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
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isSender;

  const _ChatBubble({
    required this.text,
    required this.time,
    required this.isSender,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      decoration: BoxDecoration(
        color: isSender ? Colors.blue[100] : Colors.grey[300],
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: isSender
              ? const Radius.circular(12)
              : const Radius.circular(0),
          bottomRight: isSender
              ? const Radius.circular(0)
              : const Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: isSender
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(text, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 4),
          Text(time, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
