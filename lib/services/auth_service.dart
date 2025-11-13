import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Tambahkan Web client ID dari Firebase Console
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId:
        'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com', // ganti dengan milikmu
    forceCodeForRefreshToken: true, // bantu refresh token biar tidak expired
  );

  Future<User?> signInWithGoogle() async {
    try {
      print("🔹 Memulai proses Google Sign-In...");
      await _googleSignIn.signOut(); // pastikan logout dulu biar tidak nyangkut
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("❌ Login dibatalkan oleh pengguna.");
        return null;
      }

      print("✅ Akun Google dipilih: ${googleUser.email}");
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print("🔹 Token diterima: ${googleAuth.idToken != null}");
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("🔹 Mencoba login ke Firebase...");
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      print("✅ Login Firebase sukses: ${userCredential.user?.email}");
      return userCredential.user;
    } catch (e) {
      print("🔥 Error Google Sign-In: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      print("✅ Logout berhasil");
    } catch (e) {
      print("🔥 Gagal logout: $e");
    }
  }
}
