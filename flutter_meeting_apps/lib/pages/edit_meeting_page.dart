// lib/pages/edit_meeting_page.dart

import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import '../services/database_service.dart';

class EditMeetingPage extends StatefulWidget {
  final models.Document meeting; // Terima seluruh dokumen meeting

  const EditMeetingPage({super.key, required this.meeting});

  @override
  State<EditMeetingPage> createState() => _EditMeetingPageState();
}

class _EditMeetingPageState extends State<EditMeetingPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _placeController;
  late TextEditingController _linkController;
  late String _selectedType;
  late DateTime _selectedDateTime;
  bool _isLoading = false;

  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    // Isi semua controller dan state dengan data dari widget.meeting
    final meetingData = widget.meeting.data;

    _titleController = TextEditingController(text: meetingData['title']);
    _descController = TextEditingController(text: meetingData['description']);
    _placeController = TextEditingController(text: meetingData['place']);
    _linkController = TextEditingController(text: meetingData['link']);
    _selectedType = meetingData['type'];
    _selectedDateTime = DateTime.parse(meetingData['meetingDateTime']);
  }

  @override
  void dispose() {
    // Jangan lupa untuk dispose controller
    _titleController.dispose();
    _descController.dispose();
    _placeController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    // Fungsi ini sama persis dengan di halaman create
    final date = await showDatePicker(
        context: context,
        initialDate: _selectedDateTime,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101));
    if (date == null) return;

    final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime));
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });
      try {
        await _databaseService.updateMeeting(
          documentId: widget.meeting.$id, // Gunakan ID dari dokumen yang ada
          title: _titleController.text,
          description: _descController.text.isEmpty ? null : _descController.text,
          meetingDateTime: _selectedDateTime,
          type: _selectedType,
          place: _placeController.text.isEmpty ? null : _placeController.text,
          link: _linkController.text.isEmpty ? null : _linkController.text,
        );
        // Kembali ke halaman sebelumnya dan kirim sinyal sukses (true)
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      } finally {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Meeting')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Judul Meeting'),
                      validator: (value) =>
                          value!.isEmpty ? 'Judul tidak boleh kosong' : null,
                    ),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(labelText: 'Deskripsi'),
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(labelText: 'Tipe Meeting'),
                      items: ['offline', 'online']
                          .map((type) =>
                              DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedType = value!),
                    ),
                    if (_selectedType == 'offline')
                      TextFormField(
                        controller: _placeController,
                        decoration: const InputDecoration(labelText: 'Lokasi'),
                      ),
                    if (_selectedType == 'online')
                      TextFormField(
                        controller: _linkController,
                        decoration:
                            const InputDecoration(labelText: 'Link Meeting (Zoom/GMeet)'),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: Text('Tanggal & Waktu: ${_selectedDateTime.toLocal()}')),
                        IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: _pickDateTime),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Simpan Perubahan'),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}