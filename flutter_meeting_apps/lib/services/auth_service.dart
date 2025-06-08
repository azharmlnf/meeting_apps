// lib/services/auth_service.dart

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../utils/appwrite_constants.dart';
import 'database_service.dart'; // Impor service

class AuthService {
  // === PERBAIKAN DI SINI ===
  // Buat instance Client sebagai static public agar bisa diakses dari luar kelas
  static final Client client = Client()
    ..setEndpoint(AppwriteConstants.endpoint)
    ..setProject(AppwriteConstants.projectId)
    ..setSelfSigned(status: true); // Hapus jika pakai SSL valid
  // ==========================

  // Gunakan 'client' yang sudah kita buat di atas
  final Account _account = Account(client); 
  
  // Inisialisasi DatabaseService langsung di sini
  final DatabaseService _databaseService = DatabaseService();

  Future<models.User> register(String name, String email, String password) async {
    try {
      // 1. Buat akun di Appwrite Auth
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      // 2. Buat profil di koleksi 'users'
      // Sekarang _databaseService sudah terinisialisasi dengan benar
      await _databaseService.createUserProfile(user: user, username: name);
      
      // 3. Langsung login setelah registrasi
      await login(email, password);
      return user;
    } on AppwriteException catch (e) {
      print('Error saat registrasi: ${e.message}');
      throw Exception(e.message ?? 'Terjadi kesalahan saat registrasi.');
    }
  }

  // Fungsi login tidak perlu diubah
  Future<models.Session> login(String email, String password) async {
    try {
      final session = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      return session;
    } on AppwriteException catch (e) {
      print('Error saat login: ${e.message}');
      throw Exception(e.message ?? 'Email atau password salah.');
    }
  }

  // Fungsi logout tidak perlu diubah
  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } on AppwriteException catch (e) {
      print('Error saat logout: ${e.message}');
      throw Exception(e.message ?? 'Gagal untuk logout.');
    }
  }

  // Fungsi getCurrentUser tidak perlu diubah
  Future<models.User?> getCurrentUser() async {
    try {
      final user = await _account.get();
      return user;
    } on AppwriteException {
      return null;
    }
  }
}