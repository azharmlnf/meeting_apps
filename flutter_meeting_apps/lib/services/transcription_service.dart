// lib/services/transcription_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/appwrite_constants.dart';

class TranscriptionService {
  Future<String> transcribeAudio(String audioFilePath) async {
    final apiUrl = Uri.parse(HuggingFaceConstants.modelEndpoint);
    final headers = {
      'Authorization': 'Bearer ${HuggingFaceConstants.apiToken}',
    };

    // Baca file audio sebagai bytes
    final audioBytes = await File(audioFilePath).readAsBytes();

    print('Mengirim ${audioBytes.length} bytes ke API Hugging Face...');

    try {
      final request = http.Request('POST', apiUrl)
        ..headers.addAll(headers)
        ..bodyBytes = audioBytes;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Jika sukses, parse JSON dan ambil teksnya
        final decodedBody = json.decode(response.body);
        return decodedBody['text'] ?? 'Tidak ada teks yang terdeteksi.';
      } else if (response.statusCode == 503) {
        // Model sedang dimuat, ini sangat umum untuk model besar seperti Whisper
        final decodedBody = json.decode(response.body);
        final estimatedTime = decodedBody['estimated_time'] ?? 0;
        throw Exception(
            'Model sedang dimuat. Coba lagi dalam ${estimatedTime.toStringAsFixed(2)} detik.');
      } else {
        // Tangani error lainnya
        throw Exception(
            'Gagal melakukan transkripsi. Status: ${response.statusCode}, Pesan: ${response.body}');
      }
    } catch (e) {
      print('Terjadi error saat transkripsi: $e');
      rethrow; // Lempar kembali error agar bisa ditangkap di UI
    }
  }
}