// lib/pages/meeting_form_page.dart

import 'package:flutter/material.dart';
import '../services/database_service.dart';

class MeetingFormPage extends StatefulWidget {
  final String userId;
  const MeetingFormPage({super.key, required this.userId});

  @override
  State<MeetingFormPage> createState() => _MeetingFormPageState();
}

class _MeetingFormPageState extends State<MeetingFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _placeController = TextEditingController();
  final _linkController = TextEditingController();
  String _selectedType = 'offline';
  DateTime _selectedDateTime = DateTime.now();
  bool _isLoading = false;

  final DatabaseService _databaseService = DatabaseService();

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

 void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });
      try {
        await _databaseService.createMeeting(
          title: _titleController.text,
          // Gunakan pengecekan .isEmpty
          description: _descController.text.isEmpty ? null : _descController.text,
          meetingDateTime: _selectedDateTime,
          type: _selectedType,
          place: _placeController.text.isEmpty ? null : _placeController.text,
          link: _linkController.text.isEmpty ? null : _linkController.text,
          createdBy: widget.userId,
        );
        Navigator.pop(context, true); 
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      } finally {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Meeting Baru')),
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
                      validator: (value) => value!.isEmpty ? 'Judul tidak boleh kosong' : null,
                    ),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(labelText: 'Deskripsi'),
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(labelText: 'Tipe Meeting'),
                      items: ['offline', 'online']
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
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
                        decoration: const InputDecoration(labelText: 'Link Meeting (Zoom/GMeet)'),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: Text('Tanggal & Waktu: ${_selectedDateTime.toLocal()}')),
                        IconButton(icon: const Icon(Icons.calendar_today), onPressed: _pickDateTime),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Simpan Meeting'),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}