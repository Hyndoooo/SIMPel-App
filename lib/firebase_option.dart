import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Konfigurasi default Firebase untuk semua platform.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      // kalau nanti kamu tambahkan iOS, bisa tambahkan di sini juga
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions belum diatur untuk platform ini',
        );
    }
  }

  // Web (boleh kosong dulu kalau belum pakai)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "GANTI_DENGAN_API_KEY_WEB",
    appId: "GANTI_DENGAN_APP_ID_WEB",
    messagingSenderId: "GANTI_DENGAN_SENDER_ID",
    projectId: "simpel-f51bf",
    authDomain: "simpel-f51bf.firebaseapp.com",
    storageBucket: "simpel-f51bf.firebasestorage.app",
  );

  // ✅ Android (berdasarkan google-services.json kamu)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDtPWUHhLikaCAk-aO6esoNr6IRsB2Nces",
    appId: "1:938759955173:android:4d190f3bedeefdc3f26a0c",
    messagingSenderId: "938759955173",
    projectId: "simpel-f51bf",
    storageBucket: "simpel-f51bf.firebasestorage.app",
  );
}
