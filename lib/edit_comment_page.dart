import 'package:flutter/material.dart';

// Halaman untuk mengedit komentar yang sudah ada
class EditCommentPage extends StatefulWidget {
  // Konten awal komentar yang akan diedit
  final String initialContent;

  const EditCommentPage({super.key, required this.initialContent});

  @override
  State<EditCommentPage> createState() => _EditCommentPageState();
}

class _EditCommentPageState extends State<EditCommentPage> {
  // Controller untuk mengelola input teks komentar
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Menginisialisasi controller dengan konten awal
    _controller = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    // Membersihkan controller saat widget dihapus
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar dengan judul "Edit Komentar"
      appBar: AppBar(
        title:
            const Text('Edit Komentar', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        // Tombol untuk menyimpan perubahan
        actions: [
          TextButton(
            onPressed: () {
              // Mengembalikan konten yang sudah diedit ke halaman sebelumnya
              Navigator.pop(context, _controller.text);
            },
            child: const Text(
              'Simpan',
              style: TextStyle(color: Color(0xFF7C3AED)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input teks untuk mengedit komentar
            TextField(
              controller: _controller,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Tulis komentar Anda...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
