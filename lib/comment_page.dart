import 'package:flutter/material.dart';
import 'post_repository.dart';
import 'user_repository.dart';
import 'edit_comment_page.dart';

// Halaman untuk menampilkan dan mengelola komentar
class CommentPage extends StatefulWidget {
  // postIndex digunakan untuk mengetahui post mana yang sedang dilihat
  final int postIndex;
  const CommentPage({super.key, required this.postIndex});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  // Controller untuk mengelola input teks komentar baru
  final TextEditingController _controller = TextEditingController();

  // Variabel untuk menyimpan alasan pelaporan komentar
  String? _selectedReason;

  // Daftar alasan yang bisa dipilih saat melaporkan komentar
  final List<String> _reportReasons = [
    'Spam',
    'Kekerasan',
    'Penyebaran hoax',
    'Pelecehan',
    'Lainnya',
  ];

  @override
  Widget build(BuildContext context) {
    // Mengambil data post yang sedang dilihat
    final post = PostRepository.posts.value[widget.postIndex];
    // Mengambil daftar komentar dari post tersebut
    final comments = List<Map<String, String>>.from(post['comments'] ?? []);
    // Mengambil data user yang sedang login
    final user = UserRepository.currentUser;

    return Scaffold(
      // AppBar dengan judul "Komentar"
      appBar: AppBar(
        title: const Text('Komentar', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Bagian untuk menampilkan daftar komentar
          Expanded(
            child: ListView(
              children: [
                // Menampilkan post yang sedang dilihat
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(post['avatar']),
                  ),
                  title: Text(post['name']),
                  subtitle: Text(post['content']),
                ),
                const Divider(),
                // Menampilkan daftar komentar
                ...comments.map(
                  (c) => ListTile(
                    // Avatar pengguna yang berkomentar
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(c['avatar']!),
                    ),
                    // Nama pengguna yang berkomentar
                    title: Text(c['name']!),
                    // Isi komentar
                    subtitle: Text(c['content']!),
                    // Menu untuk edit/delete/report komentar
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'report') {
                          // Menampilkan dialog untuk melaporkan komentar
                          _showReportDialog(context, c);
                        } else if (value == 'edit' &&
                            c['username'] == user['username']) {
                          // Membuka halaman edit komentar
                          final editedContent = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditCommentPage(
                                  initialContent: c['content']!),
                            ),
                          );
                          // Jika ada perubahan, update komentar
                          if (editedContent != null) {
                            setState(() {
                              PostRepository.editComment(
                                  widget.postIndex, c, editedContent);
                            });
                          }
                        } else if (value == 'delete' &&
                            c['username'] == user['username']) {
                          // Menghapus komentar
                          setState(() {
                            PostRepository.deleteComment(widget.postIndex, c);
                          });
                          // Menampilkan pesan sukses
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Komentar berhasil dihapus')),
                          );
                        }
                      },
                      // Menu yang ditampilkan saat tombol menu ditekan
                      itemBuilder: (context) => [
                        // Menu edit hanya muncul jika user adalah pemilik komentar
                        if (c['username'] == user['username'])
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Edit Komentar'),
                          ),
                        // Menu delete hanya muncul jika user adalah pemilik komentar
                        if (c['username'] == user['username'])
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Hapus Komentar'),
                          ),
                        // Menu report hanya muncul jika user bukan pemilik komentar
                        if (c['username'] != user['username'])
                          const PopupMenuItem<String>(
                            value: 'report',
                            child: Text('Laporkan Komentar'),
                          ),
                        const PopupMenuItem<String>(
                          value: 'cancel',
                          child: Text('Batal'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bagian untuk menambah komentar baru
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Avatar user yang sedang login
                CircleAvatar(
                  backgroundImage: AssetImage(user['avatar']!),
                  radius: 18,
                ),
                const SizedBox(width: 8),
                // Input teks untuk menulis komentar baru
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Tulis komentar...',
                    ),
                  ),
                ),
                // Tombol untuk mengirim komentar
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF7C3AED)),
                  onPressed: () {
                    // Cek apakah ada teks yang diketik
                    if (_controller.text.trim().isNotEmpty) {
                      setState(() {
                        // Menambah komentar baru
                        PostRepository.addComment(widget.postIndex, {
                          'name': user['name']!,
                          'username': user['username']!,
                          'avatar': user['avatar']!,
                          'content': _controller.text.trim(),
                          'time': 'now',
                        });
                        // Membersihkan input setelah komentar terkirim
                        _controller.clear();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menampilkan dialog pelaporan komentar
  void _showReportDialog(BuildContext context, Map<String, String> comment) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Laporkan Komentar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pilih alasan Anda melaporkan komentar ini:'),
            const SizedBox(height: 16),
            // Dropdown untuk memilih alasan pelaporan
            DropdownButton<String>(
              value: _selectedReason,
              isExpanded: true,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedReason = newValue!;
                });
              },
              items:
                  _reportReasons.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          // Tombol batal
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          // Tombol laporkan
          ElevatedButton(
            onPressed: () {
              // Menutup dialog
              Navigator.pop(context);
              // Menampilkan pesan sukses
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Komentar berhasil dilaporkan: $_selectedReason')),
              );
            },
            child: const Text('Laporkan'),
          ),
        ],
      ),
    );
  }
}
