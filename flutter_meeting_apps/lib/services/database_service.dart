// lib/services/database_service.dart

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'auth_service.dart';
import '../utils/appwrite_constants.dart';

class DatabaseService {
  final Databases _databases = Databases(AuthService.client);
  final String _dbId = AppwriteConstants.databaseId;

  // === USER PROFILE ===
  Future<void> createUserProfile({
    required models.User user,
    required String username,
  }) async {
    try {
      await _databases.createDocument(
        databaseId: _dbId,
        collectionId: AppwriteConstants.usersCollectionId,
        documentId: user.$id, // Menggunakan ID Auth sebagai ID dokumen
        data: {'username': username, 'email': user.email},
      );
    } on AppwriteException catch (e) {
      print('Error creating user profile: ${e.message}');
      throw Exception('Gagal membuat profil pengguna.');
    }
  }

  // === MEETINGS CRUD ===
  //create
  Future<void> createMeeting({
    required String title,
    String? description,
    required DateTime meetingDateTime,
    required String type,
    String? place,
    String? link,
    required String createdBy, // Ini menerima String
  }) async {
    try {
      await _databases.createDocument(
        databaseId: _dbId,
        collectionId: AppwriteConstants.meetingsCollectionId,
        documentId: ID.unique(),
        data: {
          'title': title,
          'description': description,
          'meetingDateTime': meetingDateTime.toIso8601String(),
          'type': type,
          if (place != null && place.isNotEmpty) 'place': place,
          if (link != null && link.isNotEmpty) 'link': link,
          // === PERBAIKAN DI SINI ===
          // Kirim sebagai string tunggal, BUKAN array
          'createdBy': createdBy,
          // ==========================
        },
        permissions: [
          Permission.read(Role.user(createdBy)),
          Permission.update(Role.user(createdBy)),
          Permission.delete(Role.user(createdBy)),
        ],
      );
    } on AppwriteException catch (e) {
      // Tampilkan SEMUA informasi dari error Appwrite
      print('============================================');
      print('ERROR ASLI DARI APPWRITE SAAT BUAT MEETING:');
      print('Pesan: ${e.message}');
      print('Kode: ${e.code}');
      print('Tipe: ${e.type}');
      print('Respon: ${e.response}');
      print('============================================');

      throw Exception('Gagal membuat meeting. Cek Debug Console untuk detail.');
    }
  }

// === TAMBAHKAN FUNGSI BARU INI ===
  Future<void> updateMeeting({
    required String documentId, // ID meeting yang akan di-update
    required String title,
    String? description,
    required DateTime meetingDateTime,
    required String type,
    String? place,
    String? link,
  }) async {
    try {
      await _databases.updateDocument(
        databaseId: _dbId,
        collectionId: AppwriteConstants.meetingsCollectionId,
        documentId: documentId, // Tentukan dokumen mana yang akan diubah
        data: {
          'title': title,
          'description': description,
          'meetingDateTime': meetingDateTime.toIso8601String(),
          'type': type,
          'place': place, // Kirim null jika kosong, Appwrite akan menanganinya
          'link': link,
        },
      );
    } on AppwriteException catch (e) {
      print('Error updating meeting: ${e.message}');
      throw Exception('Gagal memperbarui meeting.');
    }
  }
 // === TAMBAHKAN FUNGSI BARU INI ===
  Future<void> deleteMeeting(String documentId) async {
    try {
      await _databases.deleteDocument(
        databaseId: _dbId,
        collectionId: AppwriteConstants.meetingsCollectionId,
        documentId: documentId, // Tentukan dokumen mana yang akan dihapus
      );
    } on AppwriteException catch (e) {
      print('Error deleting meeting: ${e.message}');
      throw Exception('Gagal menghapus meeting.');
    }
  }

  // lib/services/database_service.dart

  Future<models.DocumentList> getMeetings(String userId) async {
    try {
      return await _databases.listDocuments(
        databaseId: _dbId,
        collectionId: AppwriteConstants.meetingsCollectionId,
        queries: [
          Query.equal('createdBy', [userId]),
          // Appwrite akan otomatis memfilter berdasarkan izin baca (read access)
          Query.orderDesc('\$createdAt'), // Cukup urutkan hasilnya
        ],
      );
    } on AppwriteException catch (e) {
      print('Error getting meetings: ${e.message}');
      throw Exception('Gagal memuat daftar meeting.');
    }
  }

  // Tambahkan fungsi updateMeeting dan deleteMeeting jika diperlukan

  // === NOTES CRUD ===
  Future<void> createNote({
    required String content,
    String? summary,
    required String meetingId,
    required String authorId,
  }) async {
    try {
      await _databases.createDocument(
        databaseId: _dbId,
        collectionId: AppwriteConstants.notesCollectionId,
        documentId: ID.unique(),
        data: {
          'content': content,
          'summary': summary,
          'meetingId': meetingId,
          'author': authorId,
        },
        permissions: [
          Permission.read(Role.user(authorId)),
          Permission.update(Role.user(authorId)),
          Permission.delete(Role.user(authorId)),
        ],
      );
    } on AppwriteException catch (e) {
      print('Error creating note: ${e.message}');
      throw Exception('Gagal membuat catatan.');
    }
  }

  Future<models.Document?> getNoteForMeeting(String meetingId) async {
    try {
      final result = await _databases.listDocuments(
        databaseId: _dbId,
        collectionId: AppwriteConstants.notesCollectionId,
        queries: [Query.equal('meetingId', meetingId), Query.limit(1)],
      );
      if (result.documents.isNotEmpty) {
        return result.documents.first;
      }
      return null;
    } on AppwriteException catch (e) {
      print('Error getting note: ${e.message}');
      throw Exception('Gagal memuat catatan.');
    }
  }

  // Tambahkan fungsi updateNote dan deleteNote jika diperlukan
}
