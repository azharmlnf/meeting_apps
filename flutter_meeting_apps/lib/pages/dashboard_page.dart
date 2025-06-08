// lib/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'login_page.dart';
import 'meeting_form_page.dart'; // Akan kita buat selanjutnya
import 'transcription_page.dart'; // Akan kita buat selanjutnya
import 'edit_meeting_page.dart'; // Jangan lupa import halaman baru

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  models.User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
    try {
      final user = await _authService.getCurrentUser();
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      print(e);
    }
  }

  void _handleLogout() async {
    try {
      await _authService.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // === TAMBAHKAN FUNGSI BARU UNTUK MENANGANI PENGHAPUSAN ===
  Future<void> _handleDeleteMeeting(
    String documentId,
    String meetingTitle,
  ) async {
    // Tampilkan dialog konfirmasi
    final bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus meeting "$meetingTitle"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(false); // Mengembalikan false
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
              onPressed: () {
                Navigator.of(context).pop(true); // Mengembalikan true
              },
            ),
          ],
        );
      },
    );

    // Jika pengguna mengkonfirmasi (menekan tombol 'Hapus')
    if (confirmDelete == true) {
      try {
        await _databaseService.deleteMeeting(documentId);
        // Tampilkan pesan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meeting berhasil dihapus.'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh daftar meeting
        setState(() {});
      } catch (e) {
        // Tampilkan pesan error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentUser?.name ?? 'Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.record_voice_over), // Icon baru
            tooltip: 'Transkrip Audio',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TranscriptionPage(),
                ),
              );
            },
          ),

          IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout),
        ],
      ),
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<models.DocumentList>(
              future: _databaseService.getMeetings(_currentUser!.$id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.documents.isEmpty) {
                  return const Center(child: Text('Belum ada meeting.'));
                }

                final meetings = snapshot.data!.documents;
                return ListView.builder(
                  itemCount: meetings.length,
                  itemBuilder: (context, index) {
                    final meeting = meetings[index];
                    return ListTile(
                      title: Text(meeting.data['title']),
                      subtitle: Text(
                        '${meeting.data['type']} - ${DateTime.parse(meeting.data['meetingDateTime']).toLocal()}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blueGrey,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditMeetingPage(meeting: meeting),
                                ),
                              ).then((isSuccess) {
                                if (isSuccess == true) {
                                  setState(() {});
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              // Langsung ambil data 'title' dari map 'meeting.data'
                              _handleDeleteMeeting(
                                meeting.$id,
                                meeting.data['title'],
                              );
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        // Navigasi ke halaman detail meeting (akan dibuat)
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => MeetingDetailPage(meeting: meeting)));
                      },
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman form untuk membuat meeting baru
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeetingFormPage(userId: _currentUser!.$id),
            ),
          ).then((isSuccess) {
            // 'then' akan dieksekusi saat halaman MeetingFormPage di-pop
            // Jika halaman form mengembalikan 'true' (yang kita atur di Navigator.pop),
            // maka kita refresh state halaman ini.
            if (isSuccess == true) {
              setState(() {
                // Memanggil setState() kosong sudah cukup untuk memberitahu Flutter
                // agar membangun ulang widget ini, yang akan memicu FutureBuilder lagi.
                print('Meeting berhasil dibuat, me-refresh daftar...');
              });
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
