import 'package:flutter/material.dart';

class EditPage extends StatefulWidget {
  final String initialContent;
  final List<String> initialMedia;
  final void Function(String updatedContent, List<String> updatedMedia) onSave;

  const EditPage({
    super.key,
    required this.initialContent,
    required this.initialMedia,
    required this.onSave,
  });

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController _controller;
  late List<String> selectedMedia;
  final List<String> availableMedia = [
    'assets/images/orang.png',
    'assets/images/tangan.png',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
    selectedMedia = List<String>.from(widget.initialMedia);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Postingan'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Edit konten...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: availableMedia.map((m) {
                  final isSelected = selectedMedia.contains(m);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        isSelected ? selectedMedia.remove(m) : selectedMedia.add(m);
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? const Color(0xFF7C3AED) : Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(m, width: 56, height: 56, fit: BoxFit.cover),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSave(_controller.text.trim(), selectedMedia);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
