// lib/pages/transcription_page.dart

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/transcription_service.dart';

class TranscriptionPage extends StatefulWidget {
  const TranscriptionPage({super.key});

  @override
  State<TranscriptionPage> createState() => _TranscriptionPageState();
}

class _TranscriptionPageState extends State<TranscriptionPage> {
  final TranscriptionService _transcriptionService = TranscriptionService();
  String? _pickedFilePath;
  String _transcriptionResult = '';
  String _statusMessage = 'Silakan pilih file audio (MP3, WAV, dll).';
  bool _isLoading = false;

  Future<void> _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _pickedFilePath = result.files.single.path;
          _statusMessage = 'File dipilih: ${result.files.single.name}';
          _transcriptionResult = ''; // Reset hasil sebelumnya
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error memilih file: $e';
      });
    }
  }

  Future<void> _startTranscription() async {
    if (_pickedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pilih file audio terlebih dahulu!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage =
          'Mentranskripsi... Ini mungkin memakan waktu beberapa saat.';
      _transcriptionResult = '';
    });

    try {
      final result = await _transcriptionService.transcribeAudio(
        _pickedFilePath!,
      );
      setState(() {
        _transcriptionResult = result;
        _statusMessage = 'Transkripsi Selesai!';
      });
    } catch (e) {
      setState(() {
        _transcriptionResult = 'Error: ${e.toString()}';
        _statusMessage = 'Terjadi kesalahan saat transkripsi.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transkrip Audio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tombol untuk memilih file
            ElevatedButton.icon(
              icon: const Icon(Icons.audiotrack),
              label: const Text('Pilih File Audio'),
              onPressed: _isLoading ? null : _pickAudioFile,
            ),
            const SizedBox(height: 16),

            // Status message
            Text(
              _statusMessage,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Tombol untuk memulai transkripsi
            ElevatedButton(
              onPressed: _pickedFilePath == null || _isLoading
                  ? null
                  : _startTranscription,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Mulai Transkripsi'),
            ),
            const SizedBox(height: 24),

            // Indikator Loading
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),

            // Hasil Transkripsi
            if (_transcriptionResult.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hasil Transkrip:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Divider(),
                    SelectableText(_transcriptionResult),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
